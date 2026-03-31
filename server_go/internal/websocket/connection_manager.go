package websocket

import (
	"context"
	"encoding/json"
	"strconv"
	"strings"

	"github.com/redis/go-redis/v9"
)

// ConnectionsListResult 。
type ConnectionsListResult struct {
	List  []map[string]any `json:"list"`
	Total int64            `json:"total"`
}

// ConnectionStats 。
type ConnectionStats struct {
	TotalConnections   int64 `json:"total_connections"`
	UniqueUsers        int   `json:"unique_users"`
	VisitorConnections int   `json:"visitor_connections"`
}

// GetConnectionsList 分页连接列表；userID 非空时仅该用户（访客键）下 fds。
func GetConnectionsList(ctx context.Context, rdb *redis.Client, userID *string, page, pageSize int) (ConnectionsListResult, error) {
	out := ConnectionsListResult{}
	if rdb == nil {
		return out, nil
	}
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}
	if userID != nil && strings.TrimSpace(*userID) != "" {
		uid := strings.TrimSpace(*userID)
		setKey := redisKeyUserFdsPrefix + uid
		n, err := rdb.SCard(ctx, setKey).Result()
		if err != nil {
			return out, err
		}
		members, err := rdb.SMembers(ctx, setKey).Result()
		if err != nil {
			return out, err
		}
		var list []map[string]any
		for _, fs := range members {
			raw, err := rdb.HGet(ctx, redisKeyConnectionsInfo, fs).Result()
			if err != nil || raw == "" {
				continue
			}
			var data map[string]any
			if json.Unmarshal([]byte(raw), &data) != nil {
				continue
			}
			fdNum, _ := strconv.Atoi(fs)
			data["fd"] = fdNum
			list = append(list, data)
		}
		offset := (page - 1) * pageSize
		end := offset + pageSize
		if offset > len(list) {
			offset = len(list)
		}
		if end > len(list) {
			end = len(list)
		}
		out.List = list[offset:end]
		out.Total = n
		return out, nil
	}

	totalStr, err := rdb.Get(ctx, redisKeyStatsTotal).Result()
	if err != nil && err != redis.Nil {
		return out, err
	}
	total, _ := strconv.ParseInt(totalStr, 10, 64)

	all, err := rdb.HGetAll(ctx, redisKeyConnectionsInfo).Result()
	if err != nil {
		return out, err
	}
	var list []map[string]any
	for fd, info := range all {
		var data map[string]any
		if json.Unmarshal([]byte(info), &data) != nil {
			continue
		}
		fdNum, _ := strconv.Atoi(fd)
		data["fd"] = fdNum
		list = append(list, data)
	}
	offset := (page - 1) * pageSize
	end := offset + pageSize
	if offset > len(list) {
		offset = len(list)
	}
	if end > len(list) {
		end = len(list)
	}
	out.List = list[offset:end]
	out.Total = total
	return out, nil
}

// GetConnectionStats 。
func GetConnectionStats(ctx context.Context, rdb *redis.Client) (ConnectionStats, error) {
	var s ConnectionStats
	if rdb == nil {
		return s, nil
	}
	totalStr, err := rdb.Get(ctx, redisKeyStatsTotal).Result()
	if err != nil && err != redis.Nil {
		return s, err
	}
	s.TotalConnections, _ = strconv.ParseInt(totalStr, 10, 64)

	all, err := rdb.HGetAll(ctx, redisKeyConnectionsInfo).Result()
	if err != nil {
		return s, err
	}
	userSeen := make(map[int64]struct{})
	for _, info := range all {
		var data map[string]any
		if json.Unmarshal([]byte(info), &data) != nil {
			continue
		}
		u, ok := data["user_id"]
		if !ok {
			s.VisitorConnections++
			continue
		}
		switch v := u.(type) {
		case float64:
			if v > 0 {
				userSeen[int64(v)] = struct{}{}
			} else {
				s.VisitorConnections++
			}
		case string:
			n, err := strconv.ParseInt(strings.TrimSpace(v), 10, 64)
			if err == nil && n > 0 {
				userSeen[n] = struct{}{}
			} else {
				s.VisitorConnections++
			}
		default:
			s.VisitorConnections++
		}
	}
	s.UniqueUsers = len(userSeen)
	return s, nil
}

// GetConnectionInfo 单 fd 详情（含 fd 字段）。
func GetConnectionInfo(ctx context.Context, rdb *redis.Client, fd int) (map[string]any, error) {
	if rdb == nil || fd <= 0 {
		return nil, nil
	}
	raw, err := rdb.HGet(ctx, redisKeyConnectionsInfo, strconv.Itoa(fd)).Result()
	if err != nil || raw == "" {
		return nil, err
	}
	var data map[string]any
	if json.Unmarshal([]byte(raw), &data) != nil {
		return nil, nil
	}
	data["fd"] = fd
	return data, nil
}

// IsConnectionExists 。
func IsConnectionExists(ctx context.Context, rdb *redis.Client, fd int) (bool, error) {
	if rdb == nil {
		return false, nil
	}
	return rdb.HExists(ctx, redisKeyConnectionsInfo, strconv.Itoa(fd)).Result()
}

// GetBatchUserOnlineStatus user_id -> 是否有至少一个 fd。
func GetBatchUserOnlineStatus(ctx context.Context, rdb *redis.Client, userIDs []int64) map[int64]bool {
	out := make(map[int64]bool, len(userIDs))
	if rdb == nil {
		return out
	}
	for _, uid := range userIDs {
		if uid <= 0 {
			continue
		}
		n, err := rdb.SCard(ctx, redisKeyUserFdsPrefix+strconv.FormatInt(uid, 10)).Result()
		out[uid] = err == nil && n > 0
	}
	return out
}

// FixConnectionStatsResult 。
type FixConnectionStatsResult struct {
	Before int64 `json:"before"`
	After  int64 `json:"after"`
	Fixed  bool  `json:"fixed"`
	Diff   int64 `json:"diff"`
}

// FixConnectionStats 将 ws:stats:total 纠正为 ws:connections:info 的 HLEN。
func FixConnectionStats(ctx context.Context, rdb *redis.Client) (FixConnectionStatsResult, error) {
	var r FixConnectionStatsResult
	if rdb == nil {
		return r, nil
	}
	beforeStr, err := rdb.Get(ctx, redisKeyStatsTotal).Result()
	if err != nil && err != redis.Nil {
		return r, err
	}
	r.Before, _ = strconv.ParseInt(beforeStr, 10, 64)
	actual, err := rdb.HLen(ctx, redisKeyConnectionsInfo).Result()
	if err != nil {
		return r, err
	}
	r.After = actual
	r.Diff = actual - r.Before
	r.Fixed = r.Before != r.After
	_ = rdb.Set(ctx, redisKeyStatsTotal, strconv.FormatInt(actual, 10), 0).Err()
	return r, nil
}

// ClearAllConnectionsResult 概要。
type ClearAllConnectionsResult struct {
	Success     bool           `json:"success"`
	ClearedKeys int            `json:"cleared_keys"`
	Details     map[string]int `json:"details"`
	Error       string         `json:"error,omitempty"`
}

// ClearAllConnections 清理 WS 相关 Redis 键（运维用；清理后在线推送会失效直至客户端重连）。
func ClearAllConnections(ctx context.Context, rdb *redis.Client, batchSize int) ClearAllConnectionsResult {
	out := ClearAllConnectionsResult{Details: make(map[string]int)}
	if rdb == nil {
		out.Error = "redis unavailable"
		return out
	}
	if batchSize < 1 {
		batchSize = 100
	}
	n := 0
	defer func() {
		out.Success = out.Error == ""
	}()

	if i, err := rdb.HLen(ctx, redisKeyConnectionsInfo).Result(); err == nil && i > 0 {
		if err := rdb.Del(ctx, redisKeyConnectionsInfo).Err(); err != nil {
			out.Error = err.Error()
			return out
		}
		n++
		out.Details["connections_info"] = int(i)
	}
	if err := rdb.Del(ctx, redisKeyStatsTotal).Err(); err != nil {
		out.Error = err.Error()
		return out
	}
	n++
	out.Details["stats_total"] = 1

	patterns := []string{
		redisKeyUserFdsPrefix + "*",
		redisKeyFdUser + "*",
		redisKeyLockFd + "*",
		"ws:room:*:fds",
		"ws:room:*:users",
		"ws:fd:rooms:*",
	}
	for _, pat := range patterns {
		k := scanAndUnlinkKeys(ctx, rdb, pat, batchSize)
		n += k
		out.Details[strings.TrimSuffix(pat, "*")] = k
	}
	out.ClearedKeys = n
	return out
}

func scanAndUnlinkKeys(ctx context.Context, rdb *redis.Client, pattern string, batchSize int) int {
	var cursor uint64
	deleted := 0
	batch := make([]string, 0, batchSize)
	for {
		keys, next, err := rdb.Scan(ctx, cursor, pattern, 100).Result()
		if err != nil {
			break
		}
		cursor = next
		for _, k := range keys {
			batch = append(batch, k)
			if len(batch) >= batchSize {
				deleted += len(batch)
				_ = rdb.Unlink(ctx, batch...).Err()
				batch = batch[:0]
			}
		}
		if cursor == 0 {
			break
		}
	}
	if len(batch) > 0 {
		deleted += len(batch)
		_ = rdb.Unlink(ctx, batch...).Err()
	}
	return deleted
}
