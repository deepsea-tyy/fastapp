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
     * 字段: fd => json(user_id, connect_time, ip, user_agent, last_ping_time)
     */
    private const REDIS_KEY_CONNECTIONS_INFO = 'ws:connections:info';

    /**
     * Redis key: ws:stats:total (String)
     * 当前总连接数
     */
    private const REDIS_KEY_STATS_TOTAL = 'ws:stats:total';

    /**
     * Redis key: ws:user:info:{user_id} (Hash)
     * 用户连接详细信息
     * 字段: fd => json(connect_time, ip, user_agent, device_type)
     */
    private const REDIS_KEY_USER_INFO = 'ws:user:info:';

    private static function getRedis(): Redis
    {
        return ApplicationContext::getContainer()->get(Redis::class);
    }

    /**
     * 记录连接信息
     */
    public static function recordConnection(
        int $fd,
        int|string $userId,
        string $ip = '',
        string $userAgent = '',
        string $deviceType = 'unknown'
    ): void {
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

        // 存储用户级连接信息
        $userInfoKey = self::REDIS_KEY_USER_INFO . $userId;
        $userConnectionInfo = json_encode([
            'connect_time' => $now,
            'ip' => $ip,
            'user_agent' => $userAgent,
            'device_type' => $deviceType,
        ], JSON_UNESCAPED_UNICODE);
        $redis->hSet($userInfoKey, (string)$fd, $userConnectionInfo);

        // 增加总连接数
        $redis->incr(self::REDIS_KEY_STATS_TOTAL);
    }

    /**
     * 移除连接信息
     */
    public static function removeConnection(int $fd, int|string|null $userId = null): void
    {
        $redis = self::getRedis();

        // 如果没有传userId，从连接信息中获取
        if ($userId === null) {
            $info = $redis->hGet(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd);
            if ($info) {
                $data = json_decode($info, true);
                $userId = $data['user_id'] ?? null;
            }
        }

        // 删除全局连接信息
        $redis->hDel(self::REDIS_KEY_CONNECTIONS_INFO, (string)$fd);

        // 删除用户级连接信息
        if ($userId !== null) {
            $userInfoKey = self::REDIS_KEY_USER_INFO . $userId;
            $redis->hDel($userInfoKey, (string)$fd);

            // 如果用户没有其他连接了，删除整个hash
            if ($redis->hLen($userInfoKey) === 0) {
                $redis->del($userInfoKey);
            }
        }

        // 减少总连接数
        $redis->decr(self::REDIS_KEY_STATS_TOTAL);
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
     * 获取所有在线连接信息
     * @return array [['fd' => 123, 'user_id' => 1, 'connect_time' => 1234567890, ...], ...]
     */
    public static function getAllConnections(): array
    {
        $redis = self::getRedis();
        $connections = $redis->hGetAll(self::REDIS_KEY_CONNECTIONS_INFO);

        $result = [];
        foreach ($connections as $fd => $info) {
            $data = json_decode($info, true);
            $data['fd'] = (int)$fd;
            $result[] = $data;
        }

        return $result;
    }

    /**
     * 获取用户的所有连接详情
     */
    public static function getUserConnections(int|string $userId): array
    {
        $redis = self::getRedis();
        $userInfoKey = self::REDIS_KEY_USER_INFO . $userId;
        $connections = $redis->hGetAll($userInfoKey);

        $result = [];
        foreach ($connections as $fd => $info) {
            $data = json_decode($info, true);
            $data['fd'] = (int)$fd;
            $result[] = $data;
        }

        return $result;
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
            $userInfoKey = self::REDIS_KEY_USER_INFO . $userId;
            $result[$userId] = $redis->hLen($userInfoKey) > 0;
        }

        return $result;
    }
}
