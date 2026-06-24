<?php
/**
 * WebSocket连接管理器
 * 提供全局的连接信息查询、统计和管理能力
 */

namespace App\Websocket;

use App\Websocket\Store\WsStateStoreFactory;

class WsConnectionManager
{
    public const REDIS_KEY_CONNECTIONS_INFO = 'ws:connections:info';

    public const REDIS_KEY_STATS_TOTAL = 'ws:stats:total';

    public static function recordConnection(
        int        $fd,
        int|string $userId,
        string     $ip = '',
        string     $userAgent = '',
        string     $deviceType = 'unknown'
    ): void
    {
        $store = WsStateStoreFactory::get();
        $now = time();

        $connectionInfo = json_encode([
            'user_id' => $userId,
            'connect_time' => $now,
            'ip' => $ip,
            'user_agent' => $userAgent,
            'device_type' => $deviceType,
            'last_ping_time' => $now,
        ], JSON_UNESCAPED_UNICODE);

        $store->setConnectionInfo($fd, $connectionInfo);
        $store->incrStatsTotal();
    }

    public static function removeConnection(int $fd): void
    {
        $store = WsStateStoreFactory::get();

        if ($store->deleteConnectionInfo($fd)) {
            $store->decrStatsTotal();
        }
    }

    public static function updatePingTime(int $fd): void
    {
        $store = WsStateStoreFactory::get();
        $info = $store->getConnectionInfoJson($fd);
        if (!$info) {
            return;
        }

        $data = json_decode($info, true);
        $data['last_ping_time'] = time();
        $store->setConnectionInfo($fd, json_encode($data, JSON_UNESCAPED_UNICODE));
    }

    public static function getConnectionsList(
        int|string|null $userId = null,
        int             $page = 1,
        int             $pageSize = 20
    ): array
    {
        $store = WsStateStoreFactory::get();

        if ($userId) {
            $fds = $store->getUserFds($userId);
            $total = $store->getUserFdCount($userId);

            $result = [];
            foreach ($fds as $fd) {
                $info = $store->getConnectionInfoJson($fd);
                if ($info) {
                    $data = json_decode($info, true);
                    $data['fd'] = $fd;
                    $result[] = $data;
                }
            }

            $offset = ($page - 1) * $pageSize;

            return [
                'list' => array_slice($result, $offset, $pageSize),
                'total' => $total,
            ];
        }

        $total = $store->getStatsTotal();
        $connections = $store->getAllConnectionInfos();

        $result = [];
        foreach ($connections as $fd => $info) {
            $data = json_decode($info, true);
            $data['fd'] = (int) $fd;
            $result[] = $data;
        }

        $offset = ($page - 1) * $pageSize;

        return [
            'list' => array_slice($result, $offset, $pageSize),
            'total' => $total,
        ];
    }

    public static function getConnectionInfo(int $fd): ?array
    {
        $store = WsStateStoreFactory::get();
        $info = $store->getConnectionInfoJson($fd);
        if (!$info) {
            return null;
        }

        $data = json_decode($info, true);
        $data['fd'] = $fd;

        return $data;
    }

    public static function getStats(): array
    {
        $store = WsStateStoreFactory::get();
        $totalConnections = $store->getStatsTotal();
        $allConnections = $store->getAllConnectionInfos();

        $userIds = [];
        $visitorCount = 0;
        foreach ($allConnections as $info) {
            $data = json_decode($info, true);
            $userId = $data['user_id'] ?? null;
            if (is_numeric($userId) && $userId > 0) {
                $userIds[(int) $userId] = true;
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

    public static function isConnectionExists(int $fd): bool
    {
        return WsStateStoreFactory::get()->hasConnectionInfo($fd);
    }

    public static function getBatchUserOnlineStatus(array $userIds): array
    {
        $store = WsStateStoreFactory::get();
        $result = [];

        foreach ($userIds as $userId) {
            $result[$userId] = $store->isUserOnline($userId);
        }

        return $result;
    }

    public static function fixConnectionStats(): array
    {
        $store = WsStateStoreFactory::get();
        $beforeCount = $store->getStatsTotal();
        $actualCount = count($store->getAllConnectionInfos());
        $store->setStatsTotal($actualCount);

        return [
            'before' => $beforeCount,
            'after' => $actualCount,
            'fixed' => $beforeCount != $actualCount,
            'diff' => $actualCount - $beforeCount,
        ];
    }

    public static function clearAllConnections(int $batchSize = 100): array
    {
        return WsStateStoreFactory::get()->clearAll($batchSize);
    }
}
