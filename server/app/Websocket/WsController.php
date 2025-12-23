<?php
/**
 * FastApp.
 * 11/4/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Websocket;

use App\Common\Jwt\JwtFactory;
use App\Common\Tools;
use App\Websocket\Event\WsCloseEvent;
use App\Websocket\Event\WsLoginEvent;
use Hyperf\Context\ApplicationContext;
use Hyperf\Contract\OnCloseInterface;
use Hyperf\Contract\OnMessageInterface;
use Hyperf\Contract\OnOpenInterface;
use Hyperf\Redis\Redis;
use Hyperf\WebSocketServer\Sender;
use Lcobucci\JWT\Token\RegisteredClaims;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use ReflectionClass;
use Swoole\Coroutine;

/**
 * WebSocket 控制器
 *
 * 架构说明：
 * - Worker 进程共享处理 HTTP 和 WebSocket 请求
 * - fd（文件描述符）由 Master 进程的 Reactor 线程维护
 * - fd 业务映射存储在 Redis，所有 Worker 进程共享访问
 * - 每个消息请求在独立协程中处理，非阻塞
 */
class WsController implements OnMessageInterface, OnOpenInterface, OnCloseInterface
{
    /**
     * 动作服务对象处理映射（需要认证的接口）
     * action => handler实例
     */
    public static array $actionHandle = [];

    /**
     * 访客模式动作服务对象处理映射（无需认证的接口）
     * visitor.action => handler实例
     */
    public static array $visitorActionHandle = [];

    /**
     * 存储每个fd对应的锁值，用于安全释放锁
     * fd => lock_value
     */
    private static array $lockValues = [];

    /**
     * Redis key: ws:fd:user:{fd}
     * 存储格式: String
     * 值: user_id (字符串)
     * 说明: fd 到用户ID的映射
     */
    private const REDIS_KEY_FD_USER = 'ws:fd:user:';

    /**
     * Redis key: ws:user:fds:{user_id}
     * 存储格式: Set
     * 值: [fd1, fd2, ...] (字符串集合)
     * 说明: 用户ID到Fd列表的映射，支持多设备登录
     */
    private const REDIS_KEY_USER_FDS = 'ws:user:fds:';

    /**
     * Redis key: ws:lock:fd:{fd}
     * 存储格式: String
     * 值: lock_value (唯一标识符)
     * 说明: 分布式锁，用于保护fd的并发操作，过期时间5秒
     */
    private const REDIS_KEY_LOCK = 'ws:lock:fd:';

    public function __construct(
        protected Sender     $sender,
        protected JwtFactory $jwtFactory,
    )
    {
        $this->registerPluginHandlers();
    }

    private static function getRedis(): Redis
    {
        return ApplicationContext::getContainer()->get(Redis::class);
    }

    /**
     * 获取分布式锁（基于 Redis SETNX）
     * @param int $fd 文件描述符
     * @return bool 是否获取到锁
     */
    private function acquireLock(int $fd): bool
    {
        $redis = self::getRedis();
        $lockKey = self::REDIS_KEY_LOCK . $fd;
        $lockValue = uniqid(gethostname() . '_', true);
        $endTime = time() + 5;
        $retryCount = 0;
        $maxRetries = 5;

        while (time() < $endTime && $retryCount < $maxRetries) {
            if ($redis->set($lockKey, $lockValue, ['nx', 'ex' => 5])) {
                self::$lockValues[$fd] = $lockValue;
                return true;
            }
            $retryCount++;
            Coroutine::sleep(0.1);
        }

        return false;
    }

    /**
     * 安全释放分布式锁（使用 Lua 脚本保证原子性，避免误删其他进程的锁）
     */
    private function releaseLock(int $fd): void
    {
        if (!isset(self::$lockValues[$fd])) {
            return;
        }

        $redis = self::getRedis();
        $lockKey = self::REDIS_KEY_LOCK . $fd;
        $lockValue = self::$lockValues[$fd];

        // 使用 Lua 脚本原子性地验证并删除锁
        // 只有当锁的值匹配时才删除，避免误删其他进程的锁
        $luaScript = <<<LUA
if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
else
    return 0
end
LUA;

        try {
            $redis->eval($luaScript, [$lockKey, $lockValue], 1);
        } catch (\Throwable $e) {
            // 如果 Lua 脚本执行失败，尝试直接删除（降级处理）
            try {
                $redis->del($lockKey);
            } catch (\Throwable $delException) {
                Tools::logAsync(
                    "Failed to delete lock key for fd {$fd}: " . $delException->getMessage(),
                    'error',
                    'error',
                    'websocket'
                );
            }
        } finally {
            unset(self::$lockValues[$fd]);
        }
    }

    /**
     * WebSocket 消息处理入口
     * $params 结构 ['action'=>'xxx','data'=>[],'op_id'=>'xxx']
     */
    public function onMessage($server, $frame): void
    {
        try {
            if ($frame->opcode === WEBSOCKET_OPCODE_PING || $frame->opcode === WEBSOCKET_OPCODE_PONG) {
                return;
            }

            $params = json_decode($frame->data, true);
            if (!is_array($params)) {
                $this->sendResponse($frame->fd, WsResponse::error('Invalid JSON format'));
                return;
            }
            switch ($params['action'] ?? '') {
                case 'ping':
                case 'heartbeat':
                    // 更新心跳时间
                    WsConnectionManager::updatePingTime($frame->fd);
                    return;
                case 'login':
                    $this->login($server, $frame->fd, $params);
                    return;
            }

            $opId = $params['op_id'] ?? '';
            $action = $params['action'] ?? '';

            // 特殊处理：visitor.bind_fd 需要调用 addConnection
            if ($action === 'visitor.bind_fd') {
                $bindKey = $params['data']['bind_key'] ?? '';
                if (empty($bindKey) || !is_string($bindKey)) {
                    $this->sendResponse($frame->fd, WsResponse::error('bind_key is required and must be a non-empty string', $opId));
                    return;
                }

                if ($this->addConnection($frame->fd, $bindKey)) {
                    $response = WsResponse::success(null, 'Bind key successfully');
                } else {
                    $response = WsResponse::error('Failed to bind connection', $opId);
                }

                $this->sendResponse($frame->fd, $response->withOpId($opId));
                return;
            }

            // 检查是否为访客模式接口（以 'visitor.' 开头）
            if (str_starts_with($action, 'visitor.')) {
                // 访客模式接口，无需认证
                if (!isset(self::$visitorActionHandle[$action])) {
                    $this->sendResponse($frame->fd, WsResponse::error('Unknown visitor action', $opId));
                    return;
                }

                // 获取 bind_key（如果存在）
                $bindKey = $this->getBindKeyByFd($frame->fd);
                $response = $this->handleMessageAction($frame->fd, $action, $params['data'] ?? [], $bindKey, true);
                $this->sendResponse($frame->fd, $response->withOpId($opId));
                return;
            }

            // 普通接口，需要认证
            $userId = $this->getUserIdByFd($frame->fd);

            if ($userId === null) {
                $this->sendResponse($frame->fd, WsResponse::error('Please login first', $opId));
                return;
            }

            if (!isset(self::$actionHandle[$action])) {
                $this->sendResponse($frame->fd, WsResponse::error('Unknown action or handler not found', $opId));
                return;
            }

            $response = $this->handleMessageAction($frame->fd, $action, $params['data'] ?? [], $userId, false);
            if ($response === false) {
                $this->sendResponse($frame->fd, WsResponse::error('Unknown action or handler not found', $opId));
                return;
            }
            $this->sendResponse($frame->fd, $response->withOpId($opId));
        } catch (\Throwable $e) {
            $this->sendResponse($frame->fd, WsResponse::error("WebSocket message error: " . $e->getMessage()));
        }
    }

    public function onClose($server, int $fd, int $reactorId): void
    {
        // 获取用户ID用于后续清理
        $userId = $this->getUserIdByFd($fd);

        // 移除连接映射
        $this->removeConnection($fd);

        // 从连接管理器中移除
        WsConnectionManager::removeConnection($fd);

        // 离开所有房间
        WsRoomManager::leaveAllRooms($fd, $userId);

        // 清理锁值记录，防止内存泄漏
        if (isset(self::$lockValues[$fd])) {
            unset(self::$lockValues[$fd]);
        }
    }

    public function onOpen($server, $request): void
    {
        $fd = $request->fd;

        // 为游客生成唯一的 bind_key，但不自动绑定
        // 客户端需要主动调用 visitor.bind_fd 进行绑定
        $bindKey = $this->generateVisitorBindKey($fd);

        $this->sendResponse($fd, WsResponse::success([
            'bind_key' => $bindKey,
        ], 'connected successfully'));
    }

    /**
     * 生成游客唯一 bind_key
     * 格式: visitor_{fd}_{timestamp}_{random}
     */
    private function generateVisitorBindKey(int $fd): string
    {
        return sprintf(
            'visitor_%d_%d_%s',
            $fd,
            time(),
            bin2hex(random_bytes(8))
        );
    }

    public function login($server, int $fd, array $params): void
    {
        $tokenString = $params['data']['token'] ?? '';
        $responseFail = WsResponse::error('Failed to parse token', $params['op_id'] ?? '');
        if (empty($tokenString)) {
            $this->sendResponse($fd, $responseFail);
            return;
        }

        $scenes = ['default', 'api'];
        $userId = 0;
        foreach ($scenes as $tryScene) {
            try {
                $jwt = $this->jwtFactory->get($tryScene);
                $token = $jwt->parserAccessToken($tokenString);
                $userId = (int)$token->claims()->get(RegisteredClaims::ID);
                break;
            } catch (\Throwable $e) {
                continue;
            }
        }

        if ($userId && $this->addConnection($fd, $userId)) {
            $response = WsResponse::success(null, 'Auth successfully', $params['op_id'] ?? '');
            $this->sendResponse($fd, $response);
            return;
        }
        $this->sendResponse($fd, $responseFail);
        Tools::eventDispatcher(new WsLoginEvent($userId, $fd));
        Coroutine::create(static function () use ($server, $fd) {
            Coroutine::sleep(3);
            if ($server->exist($fd)) {
                $server->close($fd);
            }
        });
    }

    /**
     * 处理请求动作
     * @param int $fd
     * @param string $action
     * @param array $data
     * @param int|string $userIdOrBindKey 用户ID或访客bind_key
     * @param bool $isVisitor 是否为访客模式
     * @return WsResponse|false
     */
    private function handleMessageAction(int $fd, string $action, array $data, int|string $userIdOrBindKey = 0, bool $isVisitor = false): WsResponse|false
    {
        try {
            // 根据模式选择不同的处理器
            $handler = $isVisitor ? self::$visitorActionHandle[$action] : self::$actionHandle[$action];
            $method = $handler['method'];
            $instance = $handler['instance'];

            // 验证方法是否为 public
            $reflection = new \ReflectionMethod($instance, $method);
            if (!$reflection->isPublic()) {
                Tools::logAsync(
                    "Security: Attempted to call non-public method {$method} for action {$action}",
                    'error',
                    'error',
                    'websocket'
                );
                return WsResponse::error('Internal error');
            }

            /* @var WsResponse|bool $res */
            return $reflection->invokeArgs($instance, [$data, $userIdOrBindKey]);
        } catch (\Throwable $e) {
            Tools::logAsync(
                "Message action error for action {$action}, fd {$fd}: " . $e->getMessage(),
                'warning',
                'warning',
                'websocket'
            );
            return WsResponse::error('Internal error');
        }
    }

    /**
     * 扫描并注册所有插件的WebSocket消息处理器
     */
    private function registerPluginHandlers(): void
    {
        $pluginDir = BASE_PATH . '/plugin';
        if (!is_dir($pluginDir)) {
            return;
        }

        $iterator = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($pluginDir, RecursiveDirectoryIterator::SKIP_DOTS),
            RecursiveIteratorIterator::SELF_FIRST
        );

        foreach ($iterator as $file) {
            if ($file->isFile() && $file->getFilename() === 'config.json') {
                $pluginPath = $file->getPath();
                $installLockFile = $pluginPath . '/install.lock';
                if (!file_exists($installLockFile)) {
                    continue;
                }

                $websocketDir = $pluginPath . '/src/WebSocket';
                if (!is_dir($websocketDir)) {
                    continue;
                }

                $this->scanWebSocketHandlers($websocketDir);
            }
        }
    }

    /**
     * 扫描WebSocket目录下的处理器类
     */
    private function scanWebSocketHandlers(string $websocketDir): void
    {
        $files = glob($websocketDir . '/*.php');
        foreach ($files as $file) {
            $className = $this->getClassNameFromFile($file);
            if (!$className) {
                continue;
            }

            try {
                if (!class_exists($className)) {
                    continue;
                }

                $reflection = new ReflectionClass($className);
                if (!$reflection->implementsInterface(WsMessageHandlerInterface::class)) {
                    continue;
                }

                $instance = \Hyperf\Support\make($className);
                if (!$instance instanceof WsMessageHandlerInterface) {
                    continue;
                }

                // 注册需要认证的 actions
                $actions = $instance->getActions();
                foreach ($actions as $actionName => $method) {
                    if (!method_exists($instance, $method)) {
                        continue;
                    }
                    if (isset(self::$actionHandle[$actionName])) {
                        Tools::logAsync(
                            "Action {$actionName} is already registered by " . self::$actionHandle[$actionName]['class'] . ", will be overridden by {$className}",
                            'warning',
                            'warning',
                            'websocket'
                        );
                    }

                    self::$actionHandle[$actionName] = [
                        'instance' => $instance,
                        'method' => $method,
                        'class' => $className,
                    ];
                }

                // 注册访客模式 actions
                $visitorActions = $instance->getVisitorActions();
                foreach ($visitorActions as $actionName => $method) {
                    if (!method_exists($instance, $method)) {
                        continue;
                    }

                    // 确保 action 以 'visitor.' 开头
                    if (!str_starts_with($actionName, 'visitor.')) {
                        Tools::logAsync(
                            "Visitor action {$actionName} in {$className} must start with 'visitor.', skipping",
                            'warning',
                            'warning',
                            'websocket'
                        );
                        continue;
                    }

                    if (isset(self::$visitorActionHandle[$actionName])) {
                        Tools::logAsync(
                            "Visitor action {$actionName} is already registered by " . self::$visitorActionHandle[$actionName]['class'] . ", will be overridden by {$className}",
                            'warning',
                            'warning',
                            'websocket'
                        );
                    }

                    self::$visitorActionHandle[$actionName] = [
                        'instance' => $instance,
                        'method' => $method,
                        'class' => $className,
                    ];
                }
            } catch (\Throwable) {
            }
        }
    }

    /**
     * 从PHP文件中提取类名
     */
    private function getClassNameFromFile(string $file): ?string
    {
        $content = file_get_contents($file);
        if (!$content) {
            return null;
        }

        if (!preg_match('/namespace\s+([^;]+);/', $content, $namespaceMatch)) {
            return null;
        }

        if (!preg_match('/class\s+(\w+)/', $content, $classMatch)) {
            return null;
        }

        $namespace = trim($namespaceMatch[1]);
        $className = $classMatch[1];

        return $namespace . '\\' . $className;
    }

    private function sendResponse(int $fd, WsResponse $response): void
    {
        try {
            $this->sender->push($fd, $response->toJson(), WEBSOCKET_OPCODE_TEXT);
        } catch (\Throwable $e) {
            $this->removeConnection($fd);
        }
    }

    /**
     * 添加连接映射（使用分布式锁保证原子性）
     * @param int $fd 文件描述符
     * @param int|string $userId 用户ID或visitor标识
     * @param string $ip 客户端IP
     * @param string $userAgent User-Agent
     * @param string $deviceType 设备类型
     * @return bool 是否成功添加连接
     */
    private function addConnection(
        int $fd,
        int|string $userId,
        string $ip = '',
        string $userAgent = '',
        string $deviceType = 'unknown'
    ): bool {
        if (!$this->acquireLock($fd)) {
            return false;
        }

        try {
            $redis = self::getRedis();
            $fdKey = self::REDIS_KEY_FD_USER . $fd;
            $userFdsKey = self::REDIS_KEY_USER_FDS . $userId;

            $oldUserId = $redis->get($fdKey);
            if ($oldUserId !== false) {
                $oldUserId = (string)$oldUserId;
                if ($oldUserId === (string)$userId) {
                    // 映射已存在且相同，直接返回
                    return true;
                }

                // 清理旧用户的映射
                $oldUserFdsKey = self::REDIS_KEY_USER_FDS . $oldUserId;
                $redis->sRem($oldUserFdsKey, (string)$fd);
                $oldUserFdsCount = $redis->sCard($oldUserFdsKey);
                if ($oldUserFdsCount === 0) {
                    $redis->del($oldUserFdsKey);
                    Tools::eventDispatcher(new WsCloseEvent($oldUserId));
                }
            }

            $redis->set($fdKey, (string)$userId);
            $redis->sAdd($userFdsKey, (string)$fd);

            // 记录连接信息到连接管理器
            WsConnectionManager::recordConnection($fd, $userId, $ip, $userAgent, $deviceType);

            return true;
        } catch (\Throwable $e) {
            Tools::logAsync(
                "Error adding connection for fd {$fd}, userId: {$userId}: " . $e->getMessage(),
                'error',
                'error',
                'websocket'
            );
            return false;
        } finally {
            $this->releaseLock($fd);
        }
    }

    /**
     * 移除连接映射（使用分布式锁保证原子性）
     */
    private function removeConnection(int $fd): void
    {
        if (!$this->acquireLock($fd)) {
            Tools::logAsync(
                "Failed to acquire lock for removing connection fd {$fd}, operation aborted to avoid data inconsistency",
                'warning',
                'warning',
                'websocket'
            );
            return;
        }

        try {
            $redis = self::getRedis();
            $fdKey = self::REDIS_KEY_FD_USER . $fd;

            $userId = $redis->get($fdKey);
            if ($userId === false) {
                return;
            }

            $userId = (string)$userId;
            $userFdsKey = self::REDIS_KEY_USER_FDS . $userId;

            $redis->sRem($userFdsKey, (string)$fd);
            $redis->del($fdKey);

            $fdsCount = $redis->sCard($userFdsKey);
            if ($fdsCount === 0) {
                $redis->del($userFdsKey);
                Tools::eventDispatcher(new WsCloseEvent($userId));
            }
        } finally {
            $this->releaseLock($fd);
        }
    }

    /**
     * 获取用户的所有连接Fd
     */
    public static function getUserFds(int|string $userId): array
    {
        $redis = self::getRedis();
        $userFdsKey = self::REDIS_KEY_USER_FDS . $userId;
        $fds = $redis->sMembers($userFdsKey);
        return $fds ? array_map('intval', $fds) : [];
    }

    /**
     * 检查用户是否在线
     */
    public static function isUserOnline(int $userId): bool
    {
        $redis = self::getRedis();
        $userFdsKey = self::REDIS_KEY_USER_FDS . $userId;
        return $redis->sCard($userFdsKey) > 0;
    }

    /**
     * 根据 fd 获取用户ID（仅限已登录用户，返回 int）
     */
    private function getUserIdByFd(int $fd): ?int
    {
        $redis = self::getRedis();
        $fdKey = self::REDIS_KEY_FD_USER . $fd;
        $userId = $redis->get($fdKey);
        return $userId !== false ? (int)$userId : null;
    }

    /**
     * 根据 fd 获取 bind_key（包括游客和已登录用户，返回 string）
     */
    private function getBindKeyByFd(int $fd): string
    {
        $redis = self::getRedis();
        $fdKey = self::REDIS_KEY_FD_USER . $fd;
        $bindKey = $redis->get($fdKey);
        return $bindKey !== false ? (string)$bindKey : '';
    }

}
