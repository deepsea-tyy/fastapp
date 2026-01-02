<?php
/**
 * FastApp - Abstract Market Process
 * 市场数据推送进程抽象基类
 *
 * 提供通用功能：
 * 1. 房间订阅者检查
 * 2. 事件推送
 * 3. 交易对管理
 * 4. 日志记录
 */

namespace Plugin\Ds\Ex\Process;

use App\Common\Tools;
use App\Websocket\Event\WsPushEvent;
use App\Websocket\WsRoomManager;
use Hyperf\Context\ApplicationContext;
use Hyperf\Process\AbstractProcess;
use Hyperf\Redis\Redis;
use Psr\EventDispatcher\EventDispatcherInterface;

abstract class AbstractMarketProcess extends AbstractProcess
{
    /**
     * 所有支持的交易对
     */
    protected array $allSymbols = [
        'BTCUSDT',
    ];

    /**
     * 基础价格
     */
    protected array $basePrices = [
        'BTCUSDT' => 40000,
    ];

    /**
     * 推送间隔（秒）
     */
    protected const PUSH_INTERVAL_SECONDS = 1;

    /**
     * 获取进程名称（用于日志）
     */
    abstract protected function getProcessName(): string;

    /**
     * 初始化进程数据
     */
    abstract protected function initializeData(): void;

    /**
     * 推送数据到订阅者
     */
    abstract protected function pushData(int $currentTime): void;

    /**
     * 主循环
     */
    public function handle(): void
    {
        $this->initializeData();
        $this->log('Process started');

        $lastPushTime = 0;

        while (true) {
            try {
                $currentTime = time();

                // 按照推送间隔推送数据
                if ($currentTime - $lastPushTime >= static::PUSH_INTERVAL_SECONDS) {
                    $this->pushData($currentTime);
                    $lastPushTime = $currentTime;
                }

                sleep(1);
            } catch (\Throwable $e) {
                $this->logError('Process error: ' . $e->getMessage());
                sleep(1);
            }
        }
    }

    /**
     * 检查房间是否有订阅者
     */
    protected function hasSubscribers(string $roomId): bool
    {
        return WsRoomManager::getRoomMemberCount($roomId) > 0;
    }

    /**
     * 获取房间订阅者数量
     */
    protected function getRoomMemberCount(string $roomId): int
    {
        return WsRoomManager::getRoomMemberCount($roomId);
    }

    /**
     * 推送事件到房间
     */
    protected function pushToRoom(string $roomId, array $data, string $event): void
    {
        $eventDispatcher = ApplicationContext::getContainer()->get(EventDispatcherInterface::class);

        $eventDispatcher->dispatch(
            WsPushEvent::toRoom(
                roomId: $roomId,
                data: $data,
                event: $event
            )
        );
    }

    /**
     * 获取 Redis 实例
     */
    protected function getRedis(): Redis
    {
        return ApplicationContext::getContainer()->get(Redis::class);
    }

    /**
     * 获取 Redis 中的价格
     */
    protected function getPriceFromRedis(string $symbol): ?float
    {
        try {
            $redis = $this->getRedis();
            $redisKey = "market:price:{$symbol}";
            $cachedPrice = $redis->get($redisKey);

            if ($cachedPrice !== false && $cachedPrice !== null) {
                return (float)$cachedPrice;
            }
        } catch (\Throwable $e) {
            // Redis 失败时返回 null
        }

        return null;
    }

    /**
     * 设置 Redis 中的价格
     */
    protected function setPriceToRedis(string $symbol, float $price, int $ttl = 3600): void
    {
        try {
            $redis = $this->getRedis();
            $redisKey = "market:price:{$symbol}";
            $redis->setex($redisKey, $ttl, (string)$price);
        } catch (\Throwable $e) {
            // Redis 失败时忽略
        }
    }

    /**
     * 格式化交易对符号（添加斜杠）
     */
    protected function formatSymbolWithSlash(string $symbol): string
    {
        $quoteCurrencies = ['USDT', 'BTC', 'ETH', 'BNB', 'USDC', 'BUSD'];
        foreach ($quoteCurrencies as $quote) {
            if (str_ends_with($symbol, $quote)) {
                return substr($symbol, 0, -strlen($quote)) . "/{$quote}";
            }
        }
        return substr($symbol, 0, -4) . '/USDT';
    }

    /**
     * 记录日志
     */
    protected function log(string $message): void
    {
//        Tools::console("[{$this->getProcessName()}] {$message}");
    }

    /**
     * 记录错误日志
     */
    protected function logError(string $message): void
    {
//        Tools::console("[{$this->getProcessName()}] ERROR: {$message}");
    }

    /**
     * 记录调试日志（带订阅者数量）
     */
    protected function logPush(string $roomId, int $memberCount, array $extra = []): void
    {
        $extraInfo = !empty($extra) ? ', ' . json_encode($extra) : '';
        $this->log("推送到房间 {$roomId}，订阅者数量: {$memberCount}{$extraInfo}");
    }
}
