<?php
/**
 * WebSocket房间管理器
 * 支持聊天室、频道等概念，用户可以加入/离开房间
 */

namespace App\Websocket;

use App\Websocket\Store\WsStateStoreFactory;

class WsRoomManager
{
    public static function joinRoom(string $roomId, int $fd, int|string|null $userId = null): bool
    {
        WsStateStoreFactory::get()->joinRoom($roomId, $fd, $userId);

        return true;
    }

    public static function leaveRoom(string $roomId, int $fd, int|string|null $userId = null): bool
    {
        WsStateStoreFactory::get()->leaveRoom($roomId, $fd, $userId);

        return true;
    }

    public static function leaveAllRooms(int $fd, int|string|null $userId = null): void
    {
        $store = WsStateStoreFactory::get();

        foreach ($store->getFdRooms($fd) as $roomId) {
            $store->leaveRoom($roomId, $fd, $userId);
        }

        $store->deleteFdRoomsKey($fd);
    }

    public static function getRoomFds(string $roomId): array
    {
        return WsStateStoreFactory::get()->getRoomFds($roomId);
    }

    public static function getRoomUserIds(string $roomId): array
    {
        return WsStateStoreFactory::get()->getRoomUserIds($roomId);
    }

    public static function getFdRooms(int $fd): array
    {
        return WsStateStoreFactory::get()->getFdRooms($fd);
    }

    public static function getRoomMemberCount(string $roomId): int
    {
        return WsStateStoreFactory::get()->getRoomMemberCount($roomId);
    }

    public static function isInRoom(string $roomId, int $fd): bool
    {
        return WsStateStoreFactory::get()->isFdInRoom($roomId, $fd);
    }

    public static function isUserInRoom(string $roomId, int|string $userId): bool
    {
        return WsStateStoreFactory::get()->isUserInRoom($roomId, $userId);
    }

    public static function getAllRooms(): array
    {
        return WsStateStoreFactory::get()->getAllRooms();
    }
}
