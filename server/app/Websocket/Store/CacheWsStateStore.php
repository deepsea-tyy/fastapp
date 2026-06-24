<?php

declare(strict_types=1);

namespace App\Websocket\Store;

use App\Common\Tools;
use Psr\SimpleCache\CacheInterface;

class CacheWsStateStore implements WsStateStore
{
    private const KEY_FD_USER = 'ws:fd:user:';

    private const KEY_USER_FDS = 'ws:user:fds:';

    private const KEY_LOCK = 'ws:lock:fd:';

    private const KEY_CONNECTIONS_INFO = 'ws:connections:info';

    private const KEY_STATS_TOTAL = 'ws:stats:total';

    private const KEY_ROOM = 'ws:room:';

    private const KEY_FD_ROOMS = 'ws:fd:rooms:';

    private const KEY_ROOM_INDEX = 'ws:room:index';

    private function cache(): CacheInterface
    {
        return Tools::getCache();
    }

    private function setMembers(string $key): array
    {
        return $this->cache()->get($key) ?: [];
    }

    private function setAdd(string $key, string $member): void
    {
        $members = $this->setMembers($key);
        if (!in_array($member, $members, true)) {
            $members[] = $member;
            $this->cache()->set($key, $members);
        }
    }

    private function setRem(string $key, string $member): void
    {
        $members = array_values(array_filter($this->setMembers($key), fn ($m) => $m != $member));
        if ($members) {
            $this->cache()->set($key, $members);
        } else {
            $this->cache()->delete($key);
        }
    }

    private function setCard(string $key): int
    {
        return count($this->setMembers($key));
    }

    private function setIsMember(string $key, string $member): bool
    {
        return in_array($member, $this->setMembers($key), true);
    }

    private function addRoomIndex(string $roomId): void
    {
        $this->setAdd(self::KEY_ROOM_INDEX, $roomId);
    }

    private function removeRoomIndex(string $roomId): void
    {
        $this->setRem(self::KEY_ROOM_INDEX, $roomId);
    }

    public function acquireFdLock(int $fd, string $lockValue, int $ttl = 5): bool
    {
        $lockKey = self::KEY_LOCK . $fd;

        if ($this->cache()->get($lockKey)) {
            return false;
        }

        return $this->cache()->set($lockKey, $lockValue, $ttl);
    }

    public function releaseFdLock(int $fd, string $lockValue): void
    {
        $lockKey = self::KEY_LOCK . $fd;

        if ($this->cache()->get($lockKey) == $lockValue) {
            $this->cache()->delete($lockKey);
        }
    }

    public function deleteFdLock(int $fd): void
    {
        $this->cache()->delete(self::KEY_LOCK . $fd);
    }

    public function addConnection(int $fd, int|string $userId, string $connectionInfoJson): array
    {
        $fdKey = self::KEY_FD_USER . $fd;
        $newUserFdsKey = self::KEY_USER_FDS . $userId;
        $fdStr = (string) $fd;
        $newUserIdStr = (string) $userId;

        $oldUserId = $this->cache()->get($fdKey);
        $oldUserIdForEvent = false;
        $isNewConnection = 0;

        if ($oldUserId && $oldUserId == $newUserIdStr) {
            $this->setConnectionInfo($fd, $connectionInfoJson);

            return [0, false];
        }

        if ($oldUserId) {
            $oldUserFdsKey = self::KEY_USER_FDS . $oldUserId;
            $this->setRem($oldUserFdsKey, $fdStr);

            if ($this->setCard($oldUserFdsKey) == 0) {
                $oldUserIdForEvent = (string) $oldUserId;
            }
        }

        if (!$this->hasConnectionInfo($fd)) {
            $isNewConnection = 1;
        }

        $this->cache()->set($fdKey, $newUserIdStr);
        $this->setAdd($newUserFdsKey, $fdStr);
        $this->setConnectionInfo($fd, $connectionInfoJson);

        if ($isNewConnection == 1) {
            $this->incrStatsTotal();
        }

        return [$isNewConnection, $oldUserIdForEvent];
    }

    public function removeConnection(int $fd): string|false
    {
        $fdKey = self::KEY_FD_USER . $fd;
        $fdStr = (string) $fd;

        $userId = $this->cache()->get($fdKey);
        if (!$userId) {
            return false;
        }

        $userFdsKey = self::KEY_USER_FDS . $userId;
        $userIdForEvent = false;

        $this->setRem($userFdsKey, $fdStr);

        if ($this->setCard($userFdsKey) == 0) {
            $userIdForEvent = (string) $userId;
        }

        $this->cache()->delete($fdKey);

        if ($this->deleteConnectionInfo($fd)) {
            $this->decrStatsTotal();
        }

        return $userIdForEvent;
    }

    public function getUserFds(int|string $userId): array
    {
        return array_map('intval', $this->setMembers(self::KEY_USER_FDS . $userId));
    }

    public function isUserOnline(int|string $userId): bool
    {
        return $this->setCard(self::KEY_USER_FDS . $userId) > 0;
    }

    public function getFdUser(int $fd): ?string
    {
        $userId = $this->cache()->get(self::KEY_FD_USER . $fd);

        return $userId ? (string) $userId : null;
    }

    public function setConnectionInfo(int $fd, string $connectionInfoJson): void
    {
        $connectionsInfo = $this->cache()->get(self::KEY_CONNECTIONS_INFO) ?: [];
        $connectionsInfo[(string) $fd] = $connectionInfoJson;
        $this->cache()->set(self::KEY_CONNECTIONS_INFO, $connectionsInfo);
    }

    public function deleteConnectionInfo(int $fd): bool
    {
        $connectionsInfo = $this->cache()->get(self::KEY_CONNECTIONS_INFO) ?: [];
        $fdStr = (string) $fd;

        if (!isset($connectionsInfo[$fdStr])) {
            return false;
        }

        unset($connectionsInfo[$fdStr]);
        $this->cache()->set(self::KEY_CONNECTIONS_INFO, $connectionsInfo);

        return true;
    }

    public function getConnectionInfoJson(int $fd): ?string
    {
        $connectionsInfo = $this->cache()->get(self::KEY_CONNECTIONS_INFO) ?: [];
        $info = $connectionsInfo[(string) $fd] ?? null;

        return $info ? (string) $info : null;
    }

    public function getAllConnectionInfos(): array
    {
        return $this->cache()->get(self::KEY_CONNECTIONS_INFO) ?: [];
    }

    public function hasConnectionInfo(int $fd): bool
    {
        $connectionsInfo = $this->cache()->get(self::KEY_CONNECTIONS_INFO) ?: [];

        return isset($connectionsInfo[(string) $fd]);
    }

    public function getStatsTotal(): int
    {
        return (int) ($this->cache()->get(self::KEY_STATS_TOTAL) ?: 0);
    }

    public function setStatsTotal(int $total): void
    {
        $this->cache()->set(self::KEY_STATS_TOTAL, $total);
    }

    public function incrStatsTotal(): void
    {
        $this->setStatsTotal($this->getStatsTotal() + 1);
    }

    public function decrStatsTotal(): void
    {
        $this->setStatsTotal(max(0, $this->getStatsTotal() - 1));
    }

    public function getUserFdCount(int|string $userId): int
    {
        return $this->setCard(self::KEY_USER_FDS . $userId);
    }

    public function joinRoom(string $roomId, int $fd, int|string|null $userId): void
    {
        $roomFdsKey = self::KEY_ROOM . $roomId . ':fds';
        $this->setAdd($roomFdsKey, (string) $fd);
        $this->setAdd(self::KEY_FD_ROOMS . $fd, $roomId);
        $this->addRoomIndex($roomId);

        if ($userId !== null) {
            $this->setAdd(self::KEY_ROOM . $roomId . ':users', (string) $userId);
        }
    }

    public function leaveRoom(string $roomId, int $fd, int|string|null $userId): void
    {
        $roomFdsKey = self::KEY_ROOM . $roomId . ':fds';
        $this->setRem($roomFdsKey, (string) $fd);
        $this->setRem(self::KEY_FD_ROOMS . $fd, $roomId);

        if ($userId !== null) {
            $roomUsersKey = self::KEY_ROOM . $roomId . ':users';
            $userHasOtherFds = false;

            foreach ($this->setMembers($roomFdsKey) as $roomFd) {
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
                $this->setRem($roomUsersKey, (string) $userId);
            }
        }

        if ($this->setCard($roomFdsKey) == 0) {
            $this->cache()->delete($roomFdsKey);
            $this->cache()->delete(self::KEY_ROOM . $roomId . ':users');
            $this->removeRoomIndex($roomId);
        }
    }

    public function deleteFdRoomsKey(int $fd): void
    {
        $this->cache()->delete(self::KEY_FD_ROOMS . $fd);
    }

    public function getRoomFds(string $roomId): array
    {
        return array_map('intval', $this->setMembers(self::KEY_ROOM . $roomId . ':fds'));
    }

    public function getRoomUserIds(string $roomId): array
    {
        $userIds = $this->setMembers(self::KEY_ROOM . $roomId . ':users');

        return array_map(fn ($id) => is_numeric($id) ? (int) $id : $id, $userIds);
    }

    public function getFdRooms(int $fd): array
    {
        return $this->setMembers(self::KEY_FD_ROOMS . $fd);
    }

    public function getRoomMemberCount(string $roomId): int
    {
        return $this->setCard(self::KEY_ROOM . $roomId . ':fds');
    }

    public function isFdInRoom(string $roomId, int $fd): bool
    {
        return $this->setIsMember(self::KEY_ROOM . $roomId . ':fds', (string) $fd);
    }

    public function isUserInRoom(string $roomId, int|string $userId): bool
    {
        return $this->setIsMember(self::KEY_ROOM . $roomId . ':users', (string) $userId);
    }

    public function getAllRooms(): array
    {
        $rooms = [];

        foreach ($this->setMembers(self::KEY_ROOM_INDEX) as $roomId) {
            $rooms[] = [
                'room_id' => $roomId,
                'member_count' => $this->getRoomMemberCount($roomId),
            ];
        }

        return $rooms;
    }

    public function clearAll(int $batchSize = 100): array
    {
        $clearedKeys = 0;
        $details = [];

        try {
            $connectionsInfo = $this->getAllConnectionInfos();
            $connectionCount = count($connectionsInfo);

            if ($connectionCount > 0) {
                $this->cache()->delete(self::KEY_CONNECTIONS_INFO);
                $clearedKeys++;
                $details['connections_info'] = $connectionCount;
            }

            if ($this->cache()->get(self::KEY_STATS_TOTAL) !== null) {
                $this->cache()->delete(self::KEY_STATS_TOTAL);
                $clearedKeys++;
                $details['stats_total'] = true;
            }

             $userFdsCount = 0;
            foreach ($connectionsInfo as $info) {
                $data = json_decode($info, true);
                $userId = $data['user_id'] ?? null;
                if ($userId) {
                    $key = self::KEY_USER_FDS . $userId;
                    if ($this->cache()->get($key) !== null) {
                        $this->cache()->delete($key);
                        $userFdsCount++;
                        $clearedKeys++;
                    }
                }
            }
            $details['user_fds_mappings'] = $userFdsCount;

            $fdUserCount = 0;
            foreach (array_keys($connectionsInfo) as $fd) {
                $key = self::KEY_FD_USER . $fd;
                if ($this->cache()->get($key) !== null) {
                    $this->cache()->delete($key);
                    $fdUserCount++;
                    $clearedKeys++;
                }
                $lockKey = self::KEY_LOCK . $fd;
                if ($this->cache()->get($lockKey) !== null) {
                    $this->cache()->delete($lockKey);
                    $clearedKeys++;
                }
            }
            $details['fd_user_mappings'] = $fdUserCount;
            $details['locks'] = 0;

            $roomFdsCount = 0;
            $roomUsersCount = 0;
            $fdRoomsCount = 0;

            foreach ($this->setMembers(self::KEY_ROOM_INDEX) as $roomId) {
                $fdsKey = self::KEY_ROOM . $roomId . ':fds';
                $usersKey = self::KEY_ROOM . $roomId . ':users';
                if ($this->cache()->get($fdsKey) !== null) {
                    $this->cache()->delete($fdsKey);
                    $roomFdsCount++;
                    $clearedKeys++;
                }
                if ($this->cache()->get($usersKey) !== null) {
                    $this->cache()->delete($usersKey);
                    $roomUsersCount++;
                    $clearedKeys++;
                }
            }
            $this->cache()->delete(self::KEY_ROOM_INDEX);
            if ($roomFdsCount) {
                $clearedKeys++;
            }

            foreach (array_keys($connectionsInfo) as $fd) {
                $fdRoomsKey = self::KEY_FD_ROOMS . $fd;
                if ($this->cache()->get($fdRoomsKey) !== null) {
                    $this->cache()->delete($fdRoomsKey);
                    $fdRoomsCount++;
                    $clearedKeys++;
                }
            }

            $details['room_fds'] = $roomFdsCount;
            $details['room_users'] = $roomUsersCount;
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
        $connections = $this->getAllConnectionInfos();
        $roomIds = $this->setMembers(self::KEY_ROOM_INDEX);

        return [
            ['ws:connections:info', 'hash', (string) count($connections)],
            ['ws:stats:total', 'string', (string) $this->getStatsTotal()],
            ['ws:user:fds:*', 'pattern', (string) count(array_unique(array_map(
                fn ($info) => (json_decode($info, true)['user_id'] ?? ''),
                $connections
            )))],
            ['ws:fd:user:*', 'pattern', (string) count($connections)],
            ['ws:lock:fd:*', 'pattern', '0'],
            ['ws:room:*:fds', 'pattern', (string) count($roomIds)],
            ['ws:room:*:users', 'pattern', (string) count($roomIds)],
            ['ws:fd:rooms:*', 'pattern', (string) count($connections)],
        ];
    }
}
