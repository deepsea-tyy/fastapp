<?php

declare(strict_types=1);

namespace App\Websocket\Store;

use Hyperf\Redis\Redis;

class RedisWsStateStore implements WsStateStore
{
    private const KEY_FD_USER = 'ws:fd:user:';

    private const KEY_USER_FDS = 'ws:user:fds:';

    private const KEY_LOCK = 'ws:lock:fd:';

    private const KEY_CONNECTIONS_INFO = 'ws:connections:info';

    private const KEY_STATS_TOTAL = 'ws:stats:total';

    private const KEY_ROOM = 'ws:room:';

    private const KEY_FD_ROOMS = 'ws:fd:rooms:';

    private const LUA_RELEASE_LOCK = <<<'LUA'
if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
else
    return 0
end
LUA;

    private const LUA_ADD_CONNECTION = <<<'LUA'
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
LUA;

    private const LUA_REMOVE_CONNECTION = <<<'LUA'
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
LUA;

    public function __construct(protected Redis $redis)
    {
    }

    public function acquireFdLock(int $fd, string $lockValue, int $ttl = 5): bool
    {
        return (bool) $this->redis->set(self::KEY_LOCK . $fd, $lockValue, ['nx', 'ex' => $ttl]);
    }

    public function releaseFdLock(int $fd, string $lockValue): void
    {
        $lockKey = self::KEY_LOCK . $fd;

        try {
            $this->redis->eval(self::LUA_RELEASE_LOCK, [$lockKey, $lockValue], 1);
        } catch (\Throwable) {
            try {
                $this->redis->del($lockKey);
            } catch (\Throwable) {
            }
        }
    }

    public function deleteFdLock(int $fd): void
    {
        $this->redis->del(self::KEY_LOCK . $fd);
    }

    public function addConnection(int $fd, int|string $userId, string $connectionInfoJson): array
    {
        $result = $this->redis->eval(
            self::LUA_ADD_CONNECTION,
            [
                self::KEY_FD_USER . $fd,
                self::KEY_USER_FDS . $userId,
                self::KEY_CONNECTIONS_INFO,
                self::KEY_STATS_TOTAL,
                (string) $userId,
                (string) $fd,
                $connectionInfoJson,
            ],
            4
        );

        return [(int) ($result[0] ?? 0), $result[1] !== false ? (string) $result[1] : false];
    }

    public function removeConnection(int $fd): string|false
    {
        $result = $this->redis->eval(
            self::LUA_REMOVE_CONNECTION,
            [
                self::KEY_FD_USER . $fd,
                self::KEY_CONNECTIONS_INFO,
                self::KEY_STATS_TOTAL,
                (string) $fd,
            ],
            3
        );

        return $result !== false ? (string) $result : false;
    }

    public function getUserFds(int|string $userId): array
    {
        $fds = $this->redis->sMembers(self::KEY_USER_FDS . $userId);

        return $fds ? array_map('intval', $fds) : [];
    }

    public function isUserOnline(int|string $userId): bool
    {
        return $this->redis->sCard(self::KEY_USER_FDS . $userId) > 0;
    }

    public function getFdUser(int $fd): ?string
    {
        $userId = $this->redis->get(self::KEY_FD_USER . $fd);

        return $userId !== false ? (string) $userId : null;
    }

    public function setConnectionInfo(int $fd, string $connectionInfoJson): void
    {
        $this->redis->hSet(self::KEY_CONNECTIONS_INFO, (string) $fd, $connectionInfoJson);
    }

    public function deleteConnectionInfo(int $fd): bool
    {
        return $this->redis->hDel(self::KEY_CONNECTIONS_INFO, (string) $fd) > 0;
    }

    public function getConnectionInfoJson(int $fd): ?string
    {
        $info = $this->redis->hGet(self::KEY_CONNECTIONS_INFO, (string) $fd);

        return $info !== false ? (string) $info : null;
    }

    public function getAllConnectionInfos(): array
    {
        $all = $this->redis->hGetAll(self::KEY_CONNECTIONS_INFO);

        return $all ?: [];
    }

    public function hasConnectionInfo(int $fd): bool
    {
        return $this->redis->hExists(self::KEY_CONNECTIONS_INFO, (string) $fd);
    }

    public function getStatsTotal(): int
    {
        return (int) ($this->redis->get(self::KEY_STATS_TOTAL) ?: 0);
    }

    public function setStatsTotal(int $total): void
    {
        $this->redis->set(self::KEY_STATS_TOTAL, $total);
    }

    public function incrStatsTotal(): void
    {
        $this->redis->incr(self::KEY_STATS_TOTAL);
    }

    public function decrStatsTotal(): void
    {
        $this->redis->decr(self::KEY_STATS_TOTAL);
    }

    public function getUserFdCount(int|string $userId): int
    {
        return $this->redis->sCard(self::KEY_USER_FDS . $userId);
    }

    public function joinRoom(string $roomId, int $fd, int|string|null $userId): void
    {
        $roomFdsKey = self::KEY_ROOM . $roomId . ':fds';
        $this->redis->sAdd($roomFdsKey, (string) $fd);
        $this->redis->sAdd(self::KEY_FD_ROOMS . $fd, $roomId);

        if ($userId !== null) {
            $this->redis->sAdd(self::KEY_ROOM . $roomId . ':users', (string) $userId);
        }
    }

    public function leaveRoom(string $roomId, int $fd, int|string|null $userId): void
    {
        $roomFdsKey = self::KEY_ROOM . $roomId . ':fds';
        $this->redis->sRem($roomFdsKey, (string) $fd);
        $this->redis->sRem(self::KEY_FD_ROOMS . $fd, $roomId);

        if ($userId !== null) {
            $roomUsersKey = self::KEY_ROOM . $roomId . ':users';
            $userHasOtherFds = false;

            foreach ($this->redis->sMembers($roomFdsKey) as $roomFd) {
                $info = $this->getConnectionInfoJson((int) $roomFd);
                if ($info) {
                    $data = json_decode($info, true);
                    if (($data['user_id'] ?? null) == $userId) {
                        $userHasOtherFds = true;
                        break;
                    }
                }
            }

            if (!$userHasOtherFds) {
                $this->redis->sRem($roomUsersKey, (string) $userId);
            }
        }

        if ($this->redis->sCard($roomFdsKey) == 0) {
            $this->redis->del($roomFdsKey);
            $this->redis->del(self::KEY_ROOM . $roomId . ':users');
        }
    }

    public function deleteFdRoomsKey(int $fd): void
    {
        $this->redis->del(self::KEY_FD_ROOMS . $fd);
    }

    public function getRoomFds(string $roomId): array
    {
        $fds = $this->redis->sMembers(self::KEY_ROOM . $roomId . ':fds');

        return $fds ? array_map('intval', $fds) : [];
    }

    public function getRoomUserIds(string $roomId): array
    {
        $userIds = $this->redis->sMembers(self::KEY_ROOM . $roomId . ':users');

        return $userIds ? array_map(fn ($id) => is_numeric($id) ? (int) $id : $id, $userIds) : [];
    }

    public function getFdRooms(int $fd): array
    {
        return $this->redis->sMembers(self::KEY_FD_ROOMS . $fd) ?: [];
    }

    public function getRoomMemberCount(string $roomId): int
    {
        return $this->redis->sCard(self::KEY_ROOM . $roomId . ':fds');
    }

    public function isFdInRoom(string $roomId, int $fd): bool
    {
        return $this->redis->sIsMember(self::KEY_ROOM . $roomId . ':fds', (string) $fd);
    }

    public function isUserInRoom(string $roomId, int|string $userId): bool
    {
        return $this->redis->sIsMember(self::KEY_ROOM . $roomId . ':users', (string) $userId);
    }

    public function getAllRooms(): array
    {
        $keys = $this->redis->keys(self::KEY_ROOM . '*:fds');
        $rooms = [];

        foreach ($keys as $key) {
            $roomId = str_replace([self::KEY_ROOM, ':fds'], '', $key);
            $rooms[] = [
                'room_id' => $roomId,
                'member_count' => $this->redis->sCard($key),
            ];
        }

        return $rooms;
    }

    public function clearAll(int $batchSize = 100): array
    {
        $clearedKeys = 0;
        $details = [];

        try {
            $connectionCount = $this->redis->hLen(self::KEY_CONNECTIONS_INFO);
            if ($connectionCount > 0) {
                $this->redis->unlink(self::KEY_CONNECTIONS_INFO);
                $clearedKeys++;
                $details['connections_info'] = $connectionCount;
            }

            if ($this->redis->exists(self::KEY_STATS_TOTAL)) {
                $this->redis->unlink(self::KEY_STATS_TOTAL);
                $clearedKeys++;
                $details['stats_total'] = true;
            }

            $userFdsCount = $this->scanAndDelete(self::KEY_USER_FDS . '*', $batchSize);
            $clearedKeys += $userFdsCount;
            $details['user_fds_mappings'] = $userFdsCount;

            $fdUserCount = $this->scanAndDelete(self::KEY_FD_USER . '*', $batchSize);
            $clearedKeys += $fdUserCount;
            $details['fd_user_mappings'] = $fdUserCount;

            $lockCount = $this->scanAndDelete(self::KEY_LOCK . '*', $batchSize);
            $clearedKeys += $lockCount;
            $details['locks'] = $lockCount;

            $roomFdsCount = $this->scanAndDelete(self::KEY_ROOM . '*:fds', $batchSize);
            $clearedKeys += $roomFdsCount;
            $details['room_fds'] = $roomFdsCount;

            $roomUsersCount = $this->scanAndDelete(self::KEY_ROOM . '*:users', $batchSize);
            $clearedKeys += $roomUsersCount;
            $details['room_users'] = $roomUsersCount;

            $fdRoomsCount = $this->scanAndDelete(self::KEY_FD_ROOMS . '*', $batchSize);
            $clearedKeys += $fdRoomsCount;
            $details['fd_rooms'] = $fdRoomsCount;

            return [
                'success' => true,
                'cleared_keys' => $clearedKeys,
                'details' => $details,
            ];
        } catch (\Throwable $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
                'cleared_keys' => $clearedKeys,
                'details' => $details,
            ];
        }
    }

    public function getStorageKeyStats(): array
    {
        return [
            ['ws:connections:info', $this->keyType(self::KEY_CONNECTIONS_INFO), $this->keySize(self::KEY_CONNECTIONS_INFO)],
            ['ws:stats:total', $this->keyType(self::KEY_STATS_TOTAL), (string) ($this->redis->get(self::KEY_STATS_TOTAL) ?: '0')],
            ['ws:user:fds:*', 'pattern', (string) $this->countKeys(self::KEY_USER_FDS . '*')],
            ['ws:fd:user:*', 'pattern', (string) $this->countKeys(self::KEY_FD_USER . '*')],
            ['ws:lock:fd:*', 'pattern', (string) $this->countKeys(self::KEY_LOCK . '*')],
            ['ws:room:*:fds', 'pattern', (string) $this->countKeys(self::KEY_ROOM . '*:fds')],
            ['ws:room:*:users', 'pattern', (string) $this->countKeys(self::KEY_ROOM . '*:users')],
            ['ws:fd:rooms:*', 'pattern', (string) $this->countKeys(self::KEY_FD_ROOMS . '*')],
        ];
    }

    private function scanAndDelete(string $pattern, int $batchSize): int
    {
        $deletedCount = 0;
        $cursor = null;
        $keysToDelete = [];

        do {
            $keys = $this->redis->scan($cursor, $pattern, 100);
            if ($keys === false) {
                break;
            }

            foreach ($keys as $key) {
                $keysToDelete[] = $key;

                if (count($keysToDelete) >= $batchSize) {
                    $this->redis->unlink(...$keysToDelete);
                    $deletedCount += count($keysToDelete);
                    $keysToDelete = [];
                    usleep(1000);
                }
            }
        } while ($cursor != 0 && $cursor !== null);

        if ($keysToDelete) {
            $this->redis->unlink(...$keysToDelete);
            $deletedCount += count($keysToDelete);
        }

        return $deletedCount;
    }

    private function countKeys(string $pattern): int
    {
        $count = 0;
        $cursor = null;

        do {
            $keys = $this->redis->scan($cursor, $pattern, 100);
            if ($keys === false) {
                break;
            }
            $count += count($keys);
        } while ($cursor != 0 && $cursor !== null);

        return $count;
    }

    private function keyType(string $key): string
    {
        if (!$this->redis->exists($key)) {
            return 'not exists';
        }

        return (string) $this->redis->type($key);
    }

    private function keySize(string $key): string
    {
        if (!$this->redis->exists($key)) {
            return '0';
        }

        $type = $this->redis->type($key);

        return match ($type) {
            Redis::REDIS_HASH => (string) $this->redis->hLen($key),
            Redis::REDIS_SET => (string) $this->redis->sCard($key),
            Redis::REDIS_ZSET => (string) $this->redis->zCard($key),
            Redis::REDIS_LIST => (string) $this->redis->lLen($key),
            Redis::REDIS_STRING => '1',
            default => '?',
        };
    }
}
