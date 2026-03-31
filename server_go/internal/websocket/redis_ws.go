package websocket

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"
)

const (
	redisKeyFdUser          = "ws:fd:user:"
	redisKeyUserFdsPrefix   = "ws:user:fds:"
	redisKeyConnectionsInfo = "ws:connections:info"
	redisKeyStatsTotal      = "ws:stats:total"
	redisKeyLockFd          = "ws:lock:fd:"
)

var lockTTL = 5 * time.Second

var luaReleaseLock = redis.NewScript(`
if redis.call("get", KEYS[1]) == ARGV[1] then
	return redis.call("del", KEYS[1])
else
	return 0
end
`)

var luaAddConnection = redis.NewScript(`
local fd_key = KEYS[1]
local new_user_fds_key = KEYS[2]
local connections_info_key = KEYS[3]
local stats_total_key = KEYS[4]
local new_user_id = ARGV[1]
local fd = ARGV[2]
local connection_info = ARGV[3]

local old_user_id = redis.call("GET", fd_key)
local old_user_id_for_event = false
local is_new_connection = 0

if old_user_id and old_user_id == new_user_id then
	redis.call("HSET", connections_info_key, fd, connection_info)
	return {0, false}
end

if old_user_id then
	local old_user_fds_key = "ws:user:fds:" .. old_user_id
	redis.call("SREM", old_user_fds_key, fd)
	local old_user_fds_count = redis.call("SCARD", old_user_fds_key)
	if old_user_fds_count == 0 then
		redis.call("DEL", old_user_fds_key)
		old_user_id_for_event = old_user_id
	end
end

if not redis.call("HEXISTS", connections_info_key, fd) then
	is_new_connection = 1
end

redis.call("SET", fd_key, new_user_id)
redis.call("SADD", new_user_fds_key, fd)
redis.call("HSET", connections_info_key, fd, connection_info)

if is_new_connection == 1 then
	redis.call("INCR", stats_total_key)
end

return {is_new_connection, old_user_id_for_event}
`)

var luaRemoveConnection = redis.NewScript(`
local fd_key = KEYS[1]
local connections_info_key = KEYS[2]
local stats_total_key = KEYS[3]
local fd = ARGV[1]

local user_id = redis.call("GET", fd_key)
if not user_id then
	return false
end

local user_fds_key = "ws:user:fds:" .. user_id
local user_id_for_event = false

redis.call("SREM", user_fds_key, fd)
local fds_count = redis.call("SCARD", user_fds_key)

if fds_count == 0 then
	redis.call("DEL", user_fds_key)
	user_id_for_event = user_id
end

redis.call("DEL", fd_key)

local deleted = redis.call("HDEL", connections_info_key, fd)
if deleted > 0 then
	redis.call("DECR", stats_total_key)
end

return user_id_for_event
`)

type lockStore struct {
	val string
}

func acquireFDLock(ctx context.Context, rdb *redis.Client, locks map[int]*lockStore, fd int) bool {
	if rdb == nil {
		return true
	}
	lockKey := redisKeyLockFd + strconv.Itoa(fd)
	end := time.Now().Add(5 * time.Second)
	for retry := 0; time.Now().Before(end) && retry < 5; retry++ {
		lv := fmt.Sprintf("%d_%d", time.Now().UnixNano(), fd)
		ok, err := rdb.SetNX(ctx, lockKey, lv, lockTTL).Result()
		if err == nil && ok {
			if locks != nil {
				locks[fd] = &lockStore{val: lv}
			}
			return true
		}
		time.Sleep(100 * time.Millisecond)
	}
	return false
}

func releaseFDLock(ctx context.Context, rdb *redis.Client, locks map[int]*lockStore, fd int) {
	if rdb == nil {
		return
	}
	lockKey := redisKeyLockFd + strconv.Itoa(fd)
	if locks != nil {
		if ls, ok := locks[fd]; ok && ls != nil {
			_, _ = luaReleaseLock.Run(ctx, rdb, []string{lockKey}, ls.val).Result()
			delete(locks, fd)
			return
		}
	}
	_ = rdb.Del(ctx, lockKey).Err()
}

func connectionInfoJSON(userID string, ip, userAgent, deviceType string, nowUnix int64) string {
	b, _ := json.Marshal(map[string]any{
		"user_id":        userID,
		"connect_time":   nowUnix,
		"ip":             ip,
		"user_agent":     userAgent,
		"device_type":    deviceType,
		"last_ping_time": nowUnix,
	})
	return string(b)
}

func wsAddConnection(ctx context.Context, rdb *redis.Client, locks map[int]*lockStore, fd int, userID string, ip, ua, device string) (closeOldUserID string, _ bool) {
	if rdb == nil {
		return "", true
	}
	if !acquireFDLock(ctx, rdb, locks, fd) {
		return "", false
	}
	defer releaseFDLock(ctx, rdb, locks, fd)

	now := time.Now().Unix()
	info := connectionInfoJSON(userID, ip, ua, device, now)
	fdStr := strconv.Itoa(fd)
	res, err := luaAddConnection.Run(ctx, rdb,
		[]string{
			redisKeyFdUser + fdStr,
			redisKeyUserFdsPrefix + userID,
			redisKeyConnectionsInfo,
			redisKeyStatsTotal,
		},
		userID, fdStr, info,
	).Result()
	if err != nil {
		return "", false
	}
	closeOldUserID = parseLuaSecondString(res)
	return closeOldUserID, true
}

func wsRemoveConnection(ctx context.Context, rdb *redis.Client, locks map[int]*lockStore, fd int) (lastUserID string) {
	if rdb == nil {
		return ""
	}
	if !acquireFDLock(ctx, rdb, locks, fd) {
		return ""
	}
	defer releaseFDLock(ctx, rdb, locks, fd)

	fdStr := strconv.Itoa(fd)
	res, err := luaRemoveConnection.Run(ctx, rdb,
		[]string{
			redisKeyFdUser + fdStr,
			redisKeyConnectionsInfo,
			redisKeyStatsTotal,
		},
		fdStr,
	).Result()
	if err != nil {
		return ""
	}
	return luaResultToUserID(res)
}

func wsUpdatePing(ctx context.Context, rdb *redis.Client, fd int) {
	if rdb == nil {
		return
	}
	fdStr := strconv.Itoa(fd)
	raw, err := rdb.HGet(ctx, redisKeyConnectionsInfo, fdStr).Result()
	if err != nil || raw == "" {
		return
	}
	var data map[string]any
	if json.Unmarshal([]byte(raw), &data) != nil {
		return
	}
	data["last_ping_time"] = time.Now().Unix()
	b, _ := json.Marshal(data)
	_ = rdb.HSet(ctx, redisKeyConnectionsInfo, fdStr, string(b)).Err()
}

func parseLuaSecondString(res interface{}) string {
	arr, ok := res.([]interface{})
	if !ok || len(arr) < 2 {
		return ""
	}
	if arr[1] == nil {
		return ""
	}
	s, _ := arr[1].(string)
	return s
}

func luaResultToUserID(res interface{}) string {
	if res == nil {
		return ""
	}
	s, ok := res.(string)
	if ok {
		return s
	}
	// go-redis 可能对 status 返回别的类型
	if b, ok := res.([]byte); ok {
		return string(b)
	}
	return ""
}
