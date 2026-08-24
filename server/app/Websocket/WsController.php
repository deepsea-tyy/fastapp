<?php
/**
 * FastApp.
 * 11/4/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Websocket;

use App\Command\Plugin\Plugin;
use App\Common\Jwt\JwtFactory;
use App\Common\Tools;
use App\Websocket\Event\WsCloseEvent;
use App\Websocket\Event\WsLoginEvent;
use App\Websocket\Store\WsStateStoreFactory;
use Hyperf\Contract\OnCloseInterface;
use Hyperf\Contract\OnMessageInterface;
use Hyperf\Contract\OnOpenInterface;
use Hyperf\WebSocketServer\Sender;
use Lcobucci\JWT\Token\RegisteredClaims;
use ReflectionClass;
use Swoole\Coroutine;
use Symfony\Component\Finder\Finder;

/**
 * WebSocket 控制器
 *
 * 架构说明：
 * - Worker 进程共享处理 HTTP 和 WebSocket 请求
 * - fd（文件描述符）由 Master 进程的 Reactor 线程维护
 * - fd 业务映射通过 WsStateStore 存储（redis/cache 可切换）
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

    private static bool $handlersRegistered = false;

    public function __construct(
        protected Sender     $sender,
        protected JwtFactory $jwtFactory,
    )
    {
        self::ensureHandlersRegistered();
    }

    // -------------------------------------------------------------------------
    // Handler 加载与注册（构造时一次性执行）
    // -------------------------------------------------------------------------

    private static function ensureHandlersRegistered(): void
    {
        if (self::$handlersRegistered) {
            return;
        }

        foreach (Plugin::getPluginJsonPaths() as $config) {
            $relative = $config->getRelativePath();
            $installLock = Tools::plugin_path($relative . '/' . Plugin::INSTALL_LOCK_FILE);
            if (!is_file($installLock)) {
                continue;
            }

            $websocketDir = Tools::plugin_path($relative . '/src/WebSocket');
            if (!is_dir($websocketDir)) {
                continue;
            }

            self::registerHandlersInDirectory($websocketDir);
        }

        self::$handlersRegistered = true;
    }

    private static function registerHandlersInDirectory(string $websocketDir): void
    {
        $finder = Finder::create()
            ->files()
            ->name('*.php')
            ->depth('== 0')
            ->in($websocketDir);

        foreach ($finder as $file) {
            self::registerHandlerFile($file->getPathname());
        }
    }

    private static function registerHandlerFile(string $file): void
    {
        $className = self::resolveClassNameFromFile($file);
        if ($className === null) {
            return;
        }

        try {
            $handler = self::resolveHandlerInstance($className);
            if ($handler === null) {
                return;
            }

            self::bindActionMap(self::$actionHandle, $handler->getActions(), $handler, $className, false);
            self::bindActionMap(self::$visitorActionHandle, $handler->getVisitorActions(), $handler, $className, true);
        } catch (\Throwable $e) {
            Tools::console("[websocket] Failed to register handler from {$file}: {$e->getMessage()}");
        }
    }

    private static function resolveHandlerInstance(string $className): ?WsMessageHandlerInterface
    {
        if (!class_exists($className)) {
            return null;
        }

        $reflection = new ReflectionClass($className);
        if (!$reflection->implementsInterface(WsMessageHandlerInterface::class)) {
            return null;
        }

        $instance = \Hyperf\Support\make($className);

        return $instance instanceof WsMessageHandlerInterface ? $instance : null;
    }

    /**
     * @param array<string, array{callable: callable, class: string}> $registry
     * @param array<string, string> $actions
     */
    private static function bindActionMap(
        array &$registry,
        array $actions,
        WsMessageHandlerInterface $handler,
        string $className,
        bool $visitor,
    ): void {
        foreach ($actions as $actionName => $method) {
            if (!method_exists($handler, $method)) {
                continue;
            }

            if ($visitor && !str_starts_with($actionName, 'visitor.')) {
                Tools::console("Visitor action {$actionName} in {$className} must start with 'visitor.', skipping");
                continue;
            }

            if (isset($registry[$actionName])) {
                $label = $visitor ? 'Visitor action' : 'Action';
                Tools::console("{$label} {$actionName} is already registered by {$registry[$actionName]['class']}, will be overridden by {$className}");
            }

            $registry[$actionName] = [
                'callable' => [$handler, $method],
                'class' => $className,
            ];
        }
    }

    private static function resolveClassNameFromFile(string $file): ?string
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

        return trim($namespaceMatch[1]) . '\\' . $classMatch[1];
    }

    private function acquireLock(int $fd): bool
    {
        $store = WsStateStoreFactory::get();
        $endTime = time() + 5;
        $retryCount = 0;
        $maxRetries = 5;

        while (time() < $endTime && $retryCount < $maxRetries) {
            $lockValue = uniqid(gethostname() . '_', true);
            if ($store->acquireFdLock($fd, $lockValue, 5)) {
                self::$lockValues[$fd] = $lockValue;
                return true;
            }
            $retryCount++;
            Coroutine::sleep(0.1);
        }

        return false;
    }

    private function releaseLock(int $fd): void
    {
        if (!isset(self::$lockValues[$fd])) {
            return;
        }

        try {
            WsStateStoreFactory::get()->releaseFdLock($fd, self::$lockValues[$fd]);
        } catch (\Throwable $e) {
            Tools::logAsync(
                "Failed to release lock for fd {$fd}: " . $e->getMessage(),
                'error',
                'error',
                'websocket'
            );
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

        // 移除连接映射（使用 Lua 脚本原子性地处理所有 Redis key，包括连接信息和统计）
        $this->removeConnection($fd);

        // 离开所有房间
        WsRoomManager::leaveAllRooms($fd, $userId);

        if (isset(self::$lockValues[$fd])) {
            try {
                WsStateStoreFactory::get()->deleteFdLock($fd);
            } catch (\Throwable $e) {
                Tools::logAsync(
                    "Failed to delete lock for fd {$fd} on close: " . $e->getMessage(),
                    'warning',
                    'warning',
                    'websocket'
                );
            } finally {
                unset(self::$lockValues[$fd]);
            }
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
            // 登录成功，触发事件
            Tools::eventDispatcher(new WsLoginEvent($userId, $fd));
            return;
        }

        // 登录失败，发送失败响应并延迟关闭连接
        $this->sendResponse($fd, $responseFail);
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
            $handlerMap = $isVisitor ? self::$visitorActionHandle : self::$actionHandle;

            if (!isset($handlerMap[$action])) {
                Tools::logAsync("Action {$action} not found", 'warn', 'websocket');
                return WsResponse::error('Invalid action');
            }

            $callable = $handlerMap[$action]['callable'];

            // 直接调用！无反射！
            /* @var WsResponse|bool $res */
            $res = $callable($data, $userIdOrBindKey);

            return $res instanceof WsResponse ? $res : WsResponse::success($res ?? []);
        } catch (\Throwable $e) {
            Tools::logAsync(
                "Action {$action} failed for fd {$fd}: " . $e->getMessage(),
                'error',
                'websocket'
            );
            return WsResponse::error('Internal error');
        }
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
     * 添加连接映射（使用分布式锁和 Lua 脚本保证原子性）
     * @param int $fd 文件描述符
     * @param int|string $userId 用户ID或visitor标识
     * @param string $ip 客户端IP
     * @param string $userAgent User-Agent
     * @param string $deviceType 设备类型
     * @return bool 是否成功添加连接
     */
    private function addConnection(
        int        $fd,
        int|string $userId,
        string     $ip = '',
        string     $userAgent = '',
        string     $deviceType = 'unknown'
    ): bool
    {
        if (!$this->acquireLock($fd)) {
            return false;
        }

        try {
            $now = time();
            $connectionInfo = json_encode([
                'user_id' => $userId,
                'connect_time' => $now,
                'ip' => $ip,
                'user_agent' => $userAgent,
                'device_type' => $deviceType,
                'last_ping_time' => $now,
            ], JSON_UNESCAPED_UNICODE);

            $result = WsStateStoreFactory::get()->addConnection($fd, $userId, $connectionInfo);

            if ($result[1] !== false) {
                Tools::eventDispatcher(new WsCloseEvent($result[1]));
            }

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
     * 移除连接映射（使用分布式锁和 Lua 脚本保证原子性）
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
            $result = WsStateStoreFactory::get()->removeConnection($fd);

            if ($result !== false) {
                Tools::eventDispatcher(new WsCloseEvent($result));
            }
        } catch (\Throwable $e) {
            Tools::logAsync(
                "Error removing connection for fd {$fd}: " . $e->getMessage(),
                'error',
                'error',
                'websocket'
            );
        } finally {
            $this->releaseLock($fd);
        }
    }

    /**
     * 获取用户的所有连接Fd
     */
    public static function getUserFds(int|string $userId): array
    {
        return WsStateStoreFactory::get()->getUserFds($userId);
    }

    public static function isUserOnline(int $userId): bool
    {
        return WsStateStoreFactory::get()->isUserOnline($userId);
    }

    private function getUserIdByFd(int $fd): ?int
    {
        $userId = WsStateStoreFactory::get()->getFdUser($fd);

        return $userId ? (int) $userId : null;
    }

    private function getBindKeyByFd(int $fd): string
    {
        return WsStateStoreFactory::get()->getFdUser($fd) ?? '';
    }

}
