<?php

declare(strict_types=1);

namespace App\Websocket\Store;

interface WsStateStore
{
    public function acquireFdLock(int $fd, string $lockValue, int $ttl = 5): bool;

    public function releaseFdLock(int $fd, string $lockValue): void;

    public function deleteFdLock(int $fd): void;

    /** @return array{0:int,1:string|false} */
    public function addConnection(int $fd, int|string $userId, string $connectionInfoJson): array;

    /** @return string|false */
    public function removeConnection(int $fd): string|false;

    public function getUserFds(int|string $userId): array;

    public function isUserOnline(int|string $userId): bool;

    public function getFdUser(int $fd): ?string;

    public function setConnectionInfo(int $fd, string $connectionInfoJson): void;

    public function deleteConnectionInfo(int $fd): bool;

    public function getConnectionInfoJson(int $fd): ?string;

    /** @return array<string, string> fd => json */
    public function getAllConnectionInfos(): array;

    public function hasConnectionInfo(int $fd): bool;

    public function getStatsTotal(): int;

    public function setStatsTotal(int $total): void;

    public function incrStatsTotal(): void;

    public function decrStatsTotal(): void;

    public function getUserFdCount(int|string $userId): int;

    public function joinRoom(string $roomId, int $fd, int|string|null $userId): void;

    public function leaveRoom(string $roomId, int $fd, int|string|null $userId): void;

    public function deleteFdRoomsKey(int $fd): void;

    public function getRoomFds(string $roomId): array;

    public function getRoomUserIds(string $roomId): array;

    public function getFdRooms(int $fd): array;

    public function getRoomMemberCount(string $roomId): int;

    public function isFdInRoom(string $roomId, int $fd): bool;

    public function isUserInRoom(string $roomId, int|string $userId): bool;

    /** @return array<int, array{room_id: string, member_count: int}> */
    public function getAllRooms(): array;

    /** @return array{success: bool, cleared_keys?: int, details?: array, error?: string} */
    public function clearAll(int $batchSize = 100): array;

    /** @return array<int, array{0: string, 1: string, 2: string}> */
    public function getStorageKeyStats(): array;
}
