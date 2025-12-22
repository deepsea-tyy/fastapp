<?php
/**
 * WebSocket房间管理器
 * 支持聊天室、频道等概念，用户可以加入/离开房间
 */

namespace App\Websocket;

use Hyperf\Context\ApplicationContext;
use Hyperf\Redis\Redis;

class WsRoomManager
{
    /**
     * Redis key: ws:room:{room_id}:fds (Set)
     * 存储房间内的所有fd
     */
    private const REDIS_KEY_ROOM_FDS = 'ws:room:';

    /**
     * Redis key: ws:fd:rooms:{fd} (Set)
     * 存储fd加入的所有房间
     */
    private const REDIS_KEY_FD_ROOMS = 'ws:fd:rooms:';

    /**
     * Redis key: ws:room:{room_id}:users (Set)
     * 存储房间内的所有user_id
     */
    private const REDIS_KEY_ROOM_USERS = 'ws:room:';

    private static function getRedis(): Redis
    {
        return ApplicationContext::getContainer()->get(Redis::class);
    }

    /**
     * 加入房间
     */
    public static function joinRoom(string $roomId, int $fd, int|string|null $userId = null): bool
    {
        $redis = self::getRedis();

        // 添加fd到房间
        $roomFdsKey = self::REDIS_KEY_ROOM_FDS . $roomId . ':fds';
        $redis->sAdd($roomFdsKey, (string)$fd);

        // 添加房间到fd的房间列表
        $fdRoomsKey = self::REDIS_KEY_FD_ROOMS . $fd;
        $redis->sAdd($fdRoomsKey, $roomId);

        // 如果有userId，添加到房间用户列表
        if ($userId !== null) {
            $roomUsersKey = self::REDIS_KEY_ROOM_USERS . $roomId . ':users';
            $redis->sAdd($roomUsersKey, (string)$userId);
        }

        return true;
    }

    /**
     * 离开房间
     */
    public static function leaveRoom(string $roomId, int $fd, int|string|null $userId = null): bool
    {
        $redis = self::getRedis();

        // 从房间移除fd
        $roomFdsKey = self::REDIS_KEY_ROOM_FDS . $roomId . ':fds';
        $redis->sRem($roomFdsKey, (string)$fd);

        // 从fd的房间列表移除房间
        $fdRoomsKey = self::REDIS_KEY_FD_ROOMS . $fd;
        $redis->sRem($fdRoomsKey, $roomId);

        // 如果有userId，从房间用户列表移除
        if ($userId !== null) {
            $roomUsersKey = self::REDIS_KEY_ROOM_USERS . $roomId . ':users';
            // 检查用户是否还有其他fd在房间内
            $userHasOtherFds = false;
            $allRoomFds = $redis->sMembers($roomFdsKey);
            foreach ($allRoomFds as $roomFd) {
                $info = WsConnectionManager::getConnectionInfo((int)$roomFd);
                if ($info && $info['user_id'] == $userId) {
                    $userHasOtherFds = true;
                    break;
                }
            }

            if (!$userHasOtherFds) {
                $redis->sRem($roomUsersKey, (string)$userId);
            }
        }

        // 如果房间为空，清理房间数据
        if ($redis->sCard($roomFdsKey) === 0) {
            $redis->del($roomFdsKey);
            $roomUsersKey = self::REDIS_KEY_ROOM_USERS . $roomId . ':users';
            $redis->del($roomUsersKey);
        }

        return true;
    }

    /**
     * fd离开所有房间（连接断开时调用）
     */
    public static function leaveAllRooms(int $fd, int|string|null $userId = null): void
    {
        $redis = self::getRedis();
        $fdRoomsKey = self::REDIS_KEY_FD_ROOMS . $fd;

        $rooms = $redis->sMembers($fdRoomsKey);
        foreach ($rooms as $roomId) {
            self::leaveRoom($roomId, $fd, $userId);
        }

        $redis->del($fdRoomsKey);
    }

    /**
     * 获取房间内的所有fd
     */
    public static function getRoomFds(string $roomId): array
    {
        $redis = self::getRedis();
        $roomFdsKey = self::REDIS_KEY_ROOM_FDS . $roomId . ':fds';
        $fds = $redis->sMembers($roomFdsKey);
        return $fds ? array_map('intval', $fds) : [];
    }

    /**
     * 获取房间内的所有用户ID
     */
    public static function getRoomUserIds(string $roomId): array
    {
        $redis = self::getRedis();
        $roomUsersKey = self::REDIS_KEY_ROOM_USERS . $roomId . ':users';
        $userIds = $redis->sMembers($roomUsersKey);
        return $userIds ? array_map(function ($id) {
            return is_numeric($id) ? (int)$id : $id;
        }, $userIds) : [];
    }

    /**
     * 获取fd加入的所有房间
     */
    public static function getFdRooms(int $fd): array
    {
        $redis = self::getRedis();
        $fdRoomsKey = self::REDIS_KEY_FD_ROOMS . $fd;
        return $redis->sMembers($fdRoomsKey) ?: [];
    }

    /**
     * 获取房间成员数量
     */
    public static function getRoomMemberCount(string $roomId): int
    {
        $redis = self::getRedis();
        $roomFdsKey = self::REDIS_KEY_ROOM_FDS . $roomId . ':fds';
        return $redis->sCard($roomFdsKey);
    }

    /**
     * 检查fd是否在房间内
     */
    public static function isInRoom(string $roomId, int $fd): bool
    {
        $redis = self::getRedis();
        $roomFdsKey = self::REDIS_KEY_ROOM_FDS . $roomId . ':fds';
        return $redis->sIsMember($roomFdsKey, (string)$fd);
    }

    /**
     * 检查用户是否在房间内
     */
    public static function isUserInRoom(string $roomId, int|string $userId): bool
    {
        $redis = self::getRedis();
        $roomUsersKey = self::REDIS_KEY_ROOM_USERS . $roomId . ':users';
        return $redis->sIsMember($roomUsersKey, (string)$userId);
    }

    /**
     * 获取所有房间列表
     */
    public static function getAllRooms(): array
    {
        $redis = self::getRedis();
        $pattern = self::REDIS_KEY_ROOM_FDS . '*:fds';
        $keys = $redis->keys($pattern);

        $rooms = [];
        foreach ($keys as $key) {
            // 从 "ws:room:room_id:fds" 提取 room_id
            $roomId = str_replace([self::REDIS_KEY_ROOM_FDS, ':fds'], '', $key);
            $memberCount = $redis->sCard($key);
            $rooms[] = [
                'room_id' => $roomId,
                'member_count' => $memberCount,
            ];
        }

        return $rooms;
    }
}
