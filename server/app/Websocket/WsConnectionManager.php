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
    private const REDIS_KEY_CONNECTIONS_INFO = 'ws:connections:info';

    /**
     * Redis key: ws:stats:total (String)
     * 当前总连接数
     */
    private const REDIS_KEY_STATS_TOTAL = 'ws:stats:total';

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
     * 包括：连接信息、统计数据、用户映射、fd映射、分布式锁
     *
     * @return array ['cleared_keys' => int, 'details' => array]
     */
    public static function clearAllConnections(): array
    {
        $redis = self::getRedis();
        $clearedKeys = 0;
        $details = [];

        try {
            // 1. 清理连接信息 Hash
            $connectionCount = $redis->hLen(self::REDIS_KEY_CONNECTIONS_INFO);
            if ($connectionCount > 0) {
                $redis->del(self::REDIS_KEY_CONNECTIONS_INFO);
                $clearedKeys++;
                $details['connections_info'] = $connectionCount;
            }

            // 2. 清理总连接数统计
            if ($redis->exists(self::REDIS_KEY_STATS_TOTAL)) {
                $redis->del(self::REDIS_KEY_STATS_TOTAL);
                $clearedKeys++;
                $details['stats_total'] = true;
            }

            // 3. 清理所有 ws:user:fds:{user_id} (用户到fd的映射)
            $userFdsPattern = self::REDIS_KEY_USER_FDS . '*';
            $userFdsKeys = $redis->keys($userFdsPattern);
            if ($userFdsKeys && count($userFdsKeys) > 0) {
                $redis->del(...$userFdsKeys);
                $clearedKeys += count($userFdsKeys);
                $details['user_fds_mappings'] = count($userFdsKeys);
            }

            // 4. 清理所有 ws:fd:user:{fd} (fd到用户的映射，来自 WsController)
            $fdUserPattern = 'ws:fd:user:*';
            $fdUserKeys = $redis->keys($fdUserPattern);
            if ($fdUserKeys && count($fdUserKeys) > 0) {
                $redis->del(...$fdUserKeys);
                $clearedKeys += count($fdUserKeys);
                $details['fd_user_mappings'] = count($fdUserKeys);
            }

            // 5. 清理所有分布式锁 ws:lock:fd:{fd} (来自 WsController)
            $lockPattern = 'ws:lock:fd:*';
            $lockKeys = $redis->keys($lockPattern);
            if ($lockKeys && count($lockKeys) > 0) {
                $redis->del(...$lockKeys);
                $clearedKeys += count($lockKeys);
                $details['locks'] = count($lockKeys);
            }

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
}
