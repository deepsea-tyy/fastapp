<?php
/**
 * WebSocket推送事件
 * 插件可以通过触发此事件来推送消息，而无需关心推送细节
 */

namespace App\Websocket\Event;

class WsPushEvent
{
    /**
     * 推送目标类型：单个用户
     */
    public const TARGET_USER = 'user';

    /**
     * 推送目标类型：多个用户
     */
    public const TARGET_USERS = 'users';

    /**
     * 推送目标类型：所有在线用户
     */
    public const TARGET_ALL = 'all';

    /**
     * 推送目标类型：指定fd
     */
    public const TARGET_FD = 'fd';

    /**
     * 推送目标类型：多个fd
     */
    public const TARGET_FDS = 'fds';

    /**
     * 推送目标类型：房间（如聊天室、频道）
     */
    public const TARGET_ROOM = 'room';

    public function __construct(
        /**
         * 推送目标类型
         */
        public readonly string $targetType,

        /**
         * 推送目标值（根据targetType不同而不同）
         * - TARGET_USER: int (user_id)
         * - TARGET_USERS: array<int> (user_ids)
         * - TARGET_ALL: null
         * - TARGET_FD: int (fd)
         * - TARGET_FDS: array<int> (fds)
         * - TARGET_ROOM: string (room_id)
         */
        public readonly mixed $target,

        /**
         * 推送数据
         */
        public readonly array $data,

        /**
         * 消息类型/事件名（可选，用于客户端区分消息）
         */
        public readonly ?string $event = null,

        /**
         * 排除的用户ID列表（可选）
         */
        public readonly array $excludeUserIds = [],

        /**
         * 排除的fd列表（可选）
         */
        public readonly array $excludeFds = [],

        /**
         * 是否只推送给在线用户（默认true，如果false则记录离线消息）
         */
        public readonly bool $onlineOnly = true,

        /**
         * 优先级（1-10，10最高，默认5）
         */
        public readonly int $priority = 5,
    ) {
    }

    /**
     * 推送给单个用户
     */
    public static function toUser(int $userId, array $data, ?string $event = null): self
    {
        return new self(
            targetType: self::TARGET_USER,
            target: $userId,
            data: $data,
            event: $event
        );
    }

    /**
     * 推送给多个用户
     */
    public static function toUsers(array $userIds, array $data, ?string $event = null): self
    {
        return new self(
            targetType: self::TARGET_USERS,
            target: $userIds,
            data: $data,
            event: $event
        );
    }

    /**
     * 推送给所有在线用户（广播）
     */
    public static function toAll(array $data, ?string $event = null, array $excludeUserIds = []): self
    {
        return new self(
            targetType: self::TARGET_ALL,
            target: null,
            data: $data,
            event: $event,
            excludeUserIds: $excludeUserIds
        );
    }

    /**
     * 推送给指定fd
     */
    public static function toFd(int $fd, array $data, ?string $event = null): self
    {
        return new self(
            targetType: self::TARGET_FD,
            target: $fd,
            data: $data,
            event: $event
        );
    }

    /**
     * 推送给多个fd
     */
    public static function toFds(array $fds, array $data, ?string $event = null): self
    {
        return new self(
            targetType: self::TARGET_FDS,
            target: $fds,
            data: $data,
            event: $event
        );
    }

    /**
     * 推送给房间内所有用户
     */
    public static function toRoom(string $roomId, array $data, ?string $event = null): self
    {
        return new self(
            targetType: self::TARGET_ROOM,
            target: $roomId,
            data: $data,
            event: $event
        );
    }
}
