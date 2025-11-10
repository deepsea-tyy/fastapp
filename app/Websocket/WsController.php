<?php
/**
 * FastApp.
 * 11/4/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Websocket;

use App\Common\Event\WsCloseEvent;
use App\Common\Jwt\JwtFactory;
use App\Common\Tools;
use Hyperf\Contract\OnCloseInterface;
use Hyperf\Contract\OnMessageInterface;
use Hyperf\Contract\OnOpenInterface;
use Hyperf\WebSocketServer\Sender;
use Lcobucci\JWT\Token\RegisteredClaims;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use ReflectionClass;
use Swoole\Coroutine;
use Swoole\Coroutine\Channel;

class WsController implements OnMessageInterface, OnOpenInterface, OnCloseInterface
{
    /**
     * 动作服务对象处理映射
     * action => handler实例
     */
    public static array $actionHandle = [];

    /**
     * Fd到用户ID的映射
     * fd => user_id
     */
    public static array $fdUser = [];

    /**
     * 用户ID到Fd列表的映射（支持多设备）
     * user_id => [fd1, fd2, ...]
     */
    public static array $userFds = [];

    /**
     * 是否已初始化
     */
    private static bool $initialized = false;

    /**
     * 协程锁，用于保护连接映射的并发操作
     */
    private static ?Channel $lock = null;

    /**
     * 锁初始化标志（使用原子操作避免竞态）
     */
    private static bool $lockInitialized = false;

    public function __construct(
        protected Sender     $sender,
        protected JwtFactory $jwtFactory,
    )
    {
        if (!self::$initialized) {
            $this->registerPluginHandlers();
            self::$initialized = true;
        }

        // 初始化协程锁（每个worker进程一个）
        self::initLock();
    }

    /**
     * 初始化锁（确保线程安全）
     */
    private static function initLock(): void
    {
        if (self::$lock !== null) {
            return;
        }

        // 使用双重检查锁定模式
        if (!self::$lockInitialized) {
            self::$lock = new Channel(1);
            self::$lock->push(true); // 初始化一个令牌
            self::$lockInitialized = true;
        }
    }

    /**
     * $params 结构 ['action'=>'xxx','data'=>[],'op_id'=>'xxx'] action动作 data请求数据 op_id操作id原样返回
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
            switch ($params['action'] ?? 'error') {
                case 'ping':
                case 'heartbeat':
                case 'error':
                    return;
                case 'login':
                    $this->login($server, $frame->fd, $params);
                    return;
            }

            $opId = $params['op_id'] ?? '';
            if (str_contains($params['action'], 'visitor')) {
                if (str_contains($params['action'], 'bind_fd')) {
                    $this->addConnection($frame->fd, $params['data']['bind_key']);
                    $response = WsResponse::success(null, 'Bind key successfully');
                } else {
                    $response = $this->handleMessageAction($frame->fd, $params['action'], $params['data'] ?? []);
                }
                $this->sendResponse($frame->fd, $response->withOpId($opId));
                return;
            }
            $userId = self::$fdUser[$frame->fd] ?? null;

            if ($userId === null) {
                $this->sendResponse($frame->fd, WsResponse::error('Please login first', $params['op_id'] ?? ''));
                return;
            }

            if (!isset(self::$actionHandle[$params['action']])) {
                $this->sendResponse($frame->fd, WsResponse::error('Unknown action or handler not found', $params['op_id'] ?? ''));
                return;
            }
            $response = $this->handleMessageAction($frame->fd, $params['action'], $params['data'] ?? [], $userId);
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
        $this->removeConnection($fd);
    }

    public function onOpen($server, $request): void
    {
        $fd = $request->fd;
        $this->sendResponse($fd, WsResponse::success(null, 'connected successfully'));
    }

    public function login($server, int $fd, array $params): void
    {
        $tokenString = $params['data']['token'] ?? '';
        try {
            if (empty($tokenString)) {
                throw new \Exception('Token is required');
            }

            $scenes = ['default', 'api'];
            $token = null;
            $lastException = null;

            foreach ($scenes as $tryScene) {
                try {
                    $jwt = $this->jwtFactory->get($tryScene);
                    $token = $jwt->parserAccessToken($tokenString);
                    break;
                } catch (\Throwable $e) {
                    $lastException = $e;
                    continue;
                }
            }

            if (!$token) {
                throw $lastException ?? new \Exception('Failed to parse token');
            }
            $userId = (int)$token->claims()->get(RegisteredClaims::ID);

            if ($userId) {
                $this->addConnection($fd, $userId);
                $response = WsResponse::success(null, 'Auth successfully', $params['op_id'] ?? '');
            } else {
                throw new \Exception('Invalid user ID from token');
            }
        } catch (\Throwable $e) {
            // 登录失败时清理可能存在的连接映射
            $this->removeConnection($fd);
            $errorMessage = $e->getMessage();
            $response = WsResponse::error('Token Auth fail: ' . $errorMessage, $params['op_id'] ?? '');
            Coroutine::create(static function () use ($server, $fd) {
                Coroutine::sleep(3);
                if ($server->exist($fd)) {
                    $server->close($fd);
                }
            });
        }

        $this->sendResponse($fd, $response);
    }

    /**
     * 处理请求动作
     * @param int $fd
     * @param string $action
     * @param array $data
     * @param int $userId
     * @return WsResponse|false
     */
    private function handleMessageAction(int $fd, string $action, array $data, int $userId = 0): WsResponse|false
    {
        try {
            $handler = self::$actionHandle[$action];
            $method = $handler['method'];
            $instance = $handler['instance'];

            // 使用反射来调用方法，支持 protected 和 private 方法
            $reflection = new \ReflectionMethod($instance, $method);
            /* @var WsResponse|bool $res */
            return $reflection->invokeArgs($instance, [$data, $userId]);
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

                $actions = $instance->getActions();
                foreach ($actions as $actionName => $method) {
                    if (!method_exists($instance, $method)) {
                        continue;
                    }
                    // 如果 action 已存在，记录警告
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

    /**
     * 发送响应消息
     */
    private function sendResponse(int $fd, WsResponse $response): void
    {
        try {
            $this->sender->push($fd, $response->toJson(), WEBSOCKET_OPCODE_TEXT);
        } catch (\Throwable $e) {
            $this->removeConnection($fd);
        }
    }

    /**
     * 添加连接映射
     */
    private function addConnection(int $fd, int|string $userId): void
    {
        // 确保锁已初始化
        self::initLock();

        // 获取锁
        self::$lock->pop();
        try {
            // 如果 fd 已经存在，先清理旧连接（处理重复登录情况）
            if (isset(self::$fdUser[$fd])) {
                $oldUserId = self::$fdUser[$fd];
                if ($oldUserId !== $userId) {
                    // fd 被分配给不同的用户，先清理旧用户的连接
                    $this->removeConnectionInternal($fd);
                } else {
                    // 同一用户重复登录，无需重复添加
                    return;
                }
            }

            self::$fdUser[$fd] = $userId;

            if (!isset(self::$userFds[$userId])) {
                self::$userFds[$userId] = [];
            }

            if (!in_array($fd, self::$userFds[$userId], true)) {
                self::$userFds[$userId][] = $fd;
            }
        } finally {
            // 释放锁
            self::$lock->push(true);
        }
    }

    /**
     * 移除连接映射（带锁保护）
     */
    private function removeConnection(int $fd): void
    {
        // 确保锁已初始化
        self::initLock();

        // 获取锁
        self::$lock->pop();
        try {
            $this->removeConnectionInternal($fd);
        } finally {
            // 释放锁
            self::$lock->push(true);
        }
    }

    /**
     * 移除连接映射（内部实现，需要调用者持有锁）
     */
    private function removeConnectionInternal(int $fd): void
    {
        if (!isset(self::$fdUser[$fd])) {
            return;
        }

        $userId = self::$fdUser[$fd];
        unset(self::$fdUser[$fd]);

        if (isset(self::$userFds[$userId])) {
            $key = array_search($fd, self::$userFds[$userId], true);
            if ($key !== false) {
                unset(self::$userFds[$userId][$key]);
                self::$userFds[$userId] = array_values(self::$userFds[$userId]);
            }

            // 如果用户没有连接了，清理数组
            if (empty(self::$userFds[$userId])) {
                unset(self::$userFds[$userId]);
                Tools::eventDispatcher(new WsCloseEvent($userId));
            }
        }
    }

    /**
     * 获取用户的所有连接Fd（读取操作，允许轻微不一致）
     */
    public static function getUserFds(int|string $userId): array
    {
        return self::$userFds[$userId] ?? [];
    }

    /**
     * 检查用户是否在线（读取操作，允许轻微不一致）
     */
    public static function isUserOnline(int $userId): bool
    {
        return isset(self::$userFds[$userId]) && !empty(self::$userFds[$userId]);
    }

}
