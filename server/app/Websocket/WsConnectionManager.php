<?php
/**
 * WebSocket连接管理器
 * 提供全局的连接信息查询、统计和管理能力
 */

namespace App\Websocket;

use Hyperf\Context\ApplicationContext;
use Hyperf\Redis\Redis;

class WsConnectionManager
{
    /**
     * Redis key: ws:connections:info (Hash)
     * 存储所有连接的详细信息
     * 字段: fd => json(user_id, connect_time, ip, user_agent, device_type, last_ping_time)
     */
    public const REDIS_KEY_CONNECTIONS_INFO = 'ws:connections:info';

    /**
     * Redis key: ws:stats:total (String)
     * 当前总连接数
     */
    public const REDIS_KEY_STATS_TOTAL = 'ws:stats:total';

    /**
     * Redis key: ws:user:fds:{user_id} (Set)
     * 用户ID到Fd列表的映射（由 WsController 维护）
     */
    private const REDIS_KEY_USER_FDS = 'ws:user:fds:';

    private static function getRedis(): Redis
    {
        return ApplicationContext::getContainer()->get(Redis::class);
    }

    /**
     * 记录连接信息
     */
    public static function recordConnection(
        int        $fd,
        int|string $userId,
        string     $ip = '',
        string     $userAgent = '',
        string     $deviceType = 'unknown'
    ): void
    {
        $redis = self::getRedis();
        $now = time();

        $connectionInfo = json_encode([
            'user_id' => $userId,
            'connect_time' => $now,
            'ip' => $ip,
            'user_agent' => $userAgent,
            'device_type' => $deviceType,
            'last_ping_time' => $now,
        ], JSON_UNESCAPED_UNICODE);

        // 存储全局连接信息
        $redis->hSet(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd, $connectionInfo);

        // 增加总连接数
        $redis->incr(self::REDIS_KEY_STATS_TOTAL);
    }

    /**
     * 移除连接信息
     */
    public static function removeConnection(int $fd): void
    {
        $redis = self::getRedis();

        // 删除全局连接信息
        $deleted = $redis->hDel(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd);

        // 只有成功删除时才减少计数
        if ($deleted > 0) {
            $redis->decr(self::REDIS_KEY_STATS_TOTAL);
        }
    }

    /**
     * 更新心跳时间
     */
    public static function updatePingTime(int $fd): void
    {
        $redis = self::getRedis();
        $info = $redis->hGet(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd);
        if (!$info) {
            return;
        }

        $data = json_decode($info, true);
        $data['last_ping_time'] = time();
        $redis->hSet(
            self::REDIS_KEY_CONNECTIONS_INFO,
            (string)$fd,
            json_encode($data, JSON_UNESCAPED_UNICODE)
        );
    }

    /**
     * 分页获取连接信息
     * @param int|string|null $userId 用户ID筛选（可选）
     * @param int $page 页码（从1开始）
     * @param int $pageSize 每页数量
     * @return array ['list' => [...], 'total' => 100]
     */
    public static function getConnectionsList(
        int|string|null $userId = null,
        int             $page = 1,
        int             $pageSize = 20
    ): array
    {
        $redis = self::getRedis();

        // 如果指定了用户ID，查询该用户的连接
        if ($userId) {
            $userFdsKey = self::REDIS_KEY_USER_FDS . $userId;
            $total = $redis->sCard($userFdsKey);
            $fds = $redis->sMembers($userFdsKey);

            $result = [];
            foreach ($fds as $fd) {
                $info = $redis->hGet(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd);
                if ($info) {
                    $data = json_decode($info, true);
                    $data['fd'] = (int)$fd;
                    $result[] = $data;
                }
            }

            $offset = ($page - 1) * $pageSize;
            return [
                'list' => array_slice($result, $offset, $pageSize),
                'total' => $total,
            ];
        }

        // 查询所有连接
        $total = (int)$redis->get(self::REDIS_KEY_STATS_TOTAL) ?: 0;
        $connections = $redis->hGetAll(self::REDIS_KEY_CONNECTIONS_INFO);

        $result = [];
        foreach ($connections as $fd => $info) {
            $data = json_decode($info, true);
            $data['fd'] = (int)$fd;
            $result[] = $data;
        }

        $offset = ($page - 1) * $pageSize;
        return [
            'list' => array_slice($result, $offset, $pageSize),
            'total' => $total,
        ];
    }

    /**
     * 获取连接详情
     */
    public static function getConnectionInfo(int $fd): ?array
    {
        $redis = self::getRedis();
        $info = $redis->hGet(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd);
        if (!$info) {
            return null;
        }

        $data = json_decode($info, true);
        $data['fd'] = $fd;
        return $data;
    }

    /**
     * 获取连接统计信息
     */
    public static function getStats(): array
    {
        $redis = self::getRedis();
        $totalConnections = (int)$redis->get(self::REDIS_KEY_STATS_TOTAL) ?: 0;
        $allConnections = $redis->hGetAll(self::REDIS_KEY_CONNECTIONS_INFO);

        $userIds = [];
        $visitorCount = 0;
        foreach ($allConnections as $info) {
            $data = json_decode($info, true);
            $userId = $data['user_id'] ?? null;
            if (is_numeric($userId) && $userId > 0) {
                $userIds[(int)$userId] = true;
            } else {
                $visitorCount++;
            }
        }

        return [
            'total_connections' => $totalConnections,
            'unique_users' => count($userIds),
            'visitor_connections' => $visitorCount,
        ];
    }

    /**
     * 检查连接是否存在
     */
    public static function isConnectionExists(int $fd): bool
    {
        $redis = self::getRedis();
        return $redis->hExists(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd);
    }

    /**
     * 批量获取用户在线状态
     * @param array $userIds
     * @return array ['user_id' => bool, ...]
     */
    public static function getBatchUserOnlineStatus(array $userIds): array
    {
        $redis = self::getRedis();
        $result = [];

        foreach ($userIds as $userId) {
            $userFdsKey = self::REDIS_KEY_USER_FDS . $userId;
            $result[$userId] = $redis->sCard($userFdsKey) > 0;
        }

        return $result;
    }

    /**
     * 修复总连接数统计
     * 当 REDIS_KEY_STATS_TOTAL 统计值与实际连接数不一致时，使用此方法修复
     * @return array ['before' => int, 'after' => int, 'fixed' => bool, 'diff' => int]
     */
    public static function fixConnectionStats(): array
    {
        $redis = self::getRedis();

        // 获取修复前的统计值
        $beforeCount = (int)$redis->get(self::REDIS_KEY_STATS_TOTAL) ?: 0;

        // 从实际连接信息中获取真实的连接数
        $actualCount = $redis->hLen(self::REDIS_KEY_CONNECTIONS_INFO);

        // 更新统计值
        $redis->set(self::REDIS_KEY_STATS_TOTAL, $actualCount);

        return [
            'before' => $beforeCount,
            'after' => $actualCount,
            'fixed' => $beforeCount !== $actualCount,
            'diff' => $actualCount - $beforeCount,
        ];
    }

    /**
     * 清理所有 WebSocket 连接相关的 Redis 数据
     * 包括：连接信息、统计数据、用户映射、fd映射、分布式锁、房间数据
     *
     * @param int $batchSize 每批删除的 key 数量（默认 100）
     * @return array ['cleared_keys' => int, 'details' => array]
     */
    public static function clearAllConnections(int $batchSize = 100): array
    {
        $redis = self::getRedis();
        $clearedKeys = 0;
        $details = [];

        try {
            // 1. 清理连接信息 Hash（使用 UNLINK 异步删除）
            $connectionCount = $redis->hLen(self::REDIS_KEY_CONNECTIONS_INFO);
            if ($connectionCount > 0) {
                $redis->unlink(self::REDIS_KEY_CONNECTIONS_INFO);
                $clearedKeys++;
                $details['connections_info'] = $connectionCount;
            }

            // 2. 清理总连接数统计
            if ($redis->exists(self::REDIS_KEY_STATS_TOTAL)) {
                $redis->unlink(self::REDIS_KEY_STATS_TOTAL);
                $clearedKeys++;
                $details['stats_total'] = true;
            }

            // 3. 使用 SCAN 清理所有 ws:user:fds:{user_id}（用户到fd的映射）
            $userFdsCount = self::scanAndDeleteKeys($redis, self::REDIS_KEY_USER_FDS . '*', $batchSize);
            $clearedKeys += $userFdsCount;
            $details['user_fds_mappings'] = $userFdsCount;

            // 4. 使用 SCAN 清理所有 ws:fd:user:{fd}（fd到用户的映射，来自 WsController）
            $fdUserCount = self::scanAndDeleteKeys($redis, 'ws:fd:user:*', $batchSize);
            $clearedKeys += $fdUserCount;
            $details['fd_user_mappings'] = $fdUserCount;

            // 5. 使用 SCAN 清理所有分布式锁 ws:lock:fd:{fd}（来自 WsController）
            $lockCount = self::scanAndDeleteKeys($redis, 'ws:lock:fd:*', $batchSize);
            $clearedKeys += $lockCount;
            $details['locks'] = $lockCount;

            // 6. 使用 SCAN 清理所有房间fd映射 ws:room:{room_id}:fds（来自 WsRoomManager）
            $roomFdsCount = self::scanAndDeleteKeys($redis, 'ws:room:*:fds', $batchSize);
            $clearedKeys += $roomFdsCount;
            $details['room_fds'] = $roomFdsCount;

            // 7. 使用 SCAN 清理所有房间用户映射 ws:room:{room_id}:users（来自 WsRoomManager）
            $roomUsersCount = self::scanAndDeleteKeys($redis, 'ws:room:*:users', $batchSize);
            $clearedKeys += $roomUsersCount;
            $details['room_users'] = $roomUsersCount;

            // 8. 使用 SCAN 清理所有fd的房间列表 ws:fd:rooms:{fd}（来自 WsRoomManager）
            $fdRoomsCount = self::scanAndDeleteKeys($redis, 'ws:fd:rooms:*', $batchSize);
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

    /**
     * 使用 SCAN 命令迭代扫描并分批删除 key
     * @param Redis $redis
     * @param string $pattern 匹配模式
     * @param int $batchSize 每批删除数量
     * @return int 删除的 key 总数
     */
    private static function scanAndDeleteKeys(Redis $redis, string $pattern, int $batchSize): int
    {
        $deletedCount = 0;
        $cursor = null;
        $keysToDelete = [];

        do {
            // 使用 SCAN 迭代扫描（每次扫描 COUNT 参数建议为 100）
            // scan() 方法通过引用参数返回新的游标，返回值是匹配的 key 数组
            $keys = $redis->scan($cursor, $pattern, 100);

            // scan 失败或无结果时返回 false
            if ($keys === false) {
                break;
            }

            // 收集 key
            foreach ($keys as $key) {
                $keysToDelete[] = $key;

                // 达到批量大小时，执行删除
                if (count($keysToDelete) >= $batchSize) {
                    // 使用 UNLINK 异步删除，不阻塞 Redis
                    $redis->unlink(...$keysToDelete);
                    $deletedCount += count($keysToDelete);
                    $keysToDelete = [];

                    // 短暂暂停，避免持续占用 Redis（可选）
                    usleep(1000); // 暂停 1 毫秒
                }
            }
        } while ($cursor !== 0 && $cursor !== null);

        // 删除剩余的 key
        if (!empty($keysToDelete)) {
            $redis->unlink(...$keysToDelete);
            $deletedCount += count($keysToDelete);
        }

        return $deletedCount;
    }
}
