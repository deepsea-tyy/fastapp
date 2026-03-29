<?php
/**
 * 查看 WebSocket 连接统计的命令
 * 显示当前所有 WebSocket 相关的 Redis 数据统计
 */

namespace App\Command;

use App\Websocket\WsConnectionManager;
use Hyperf\Command\Annotation\Command;
use Hyperf\Command\Command as HyperfCommand;
use Hyperf\Context\ApplicationContext;
use Hyperf\Redis\Redis;
use Psr\Container\ContainerInterface;

#[Command]
class WsShowStatsCommand extends HyperfCommand
{
    public function __construct(protected ContainerInterface $container)
    {
        parent::__construct('ws:stats');
    }

    public function configure(): void
    {
        parent::configure();
        $this->setDescription('查看 WebSocket 连接统计和 Redis 数据统计');
    }

    public function handle(): void
    {
        $redis = ApplicationContext::getContainer()->get(Redis::class);

        $this->line('WebSocket 连接统计信息', 'info');
        $this->line('');

        try {
            // 获取连接统计
            $stats = WsConnectionManager::getStats();
            $this->table(
                ['指标', '数值'],
                [
                    ['总连接数', $stats['total_connections']],
                    ['唯一用户数', $stats['unique_users']],
                    ['访客连接数', $stats['visitor_connections']],
                ]
            );

            $this->line('');
            $this->line('Redis Key 统计信息', 'comment');
            $this->line('');

            // 统计各类 Redis key
            $keyStats = [
                ['ws:connections:info', $this->getKeyType($redis, 'ws:connections:info'), $this->getKeySize($redis, 'ws:connections:info')],
                ['ws:stats:total', $this->getKeyType($redis, 'ws:stats:total'), $redis->get('ws:stats:total') ?: '0'],
                ['ws:user:fds:*', 'pattern', $this->countKeys($redis, 'ws:user:fds:*')],
                ['ws:fd:user:*', 'pattern', $this->countKeys($redis, 'ws:fd:user:*')],
                ['ws:lock:fd:*', 'pattern', $this->countKeys($redis, 'ws:lock:fd:*')],
                ['ws:room:*:fds', 'pattern', $this->countKeys($redis, 'ws:room:*:fds')],
                ['ws:room:*:users', 'pattern', $this->countKeys($redis, 'ws:room:*:users')],
                ['ws:fd:rooms:*', 'pattern', $this->countKeys($redis, 'ws:fd:rooms:*')],
            ];

            $this->table(
                ['Key 模式', '类型', '数量/值'],
                $keyStats
            );

            // 检查统计一致性
            $this->line('');
            $actualConnections = $redis->hLen('ws:connections:info');
            $statsTotal = (int)($redis->get('ws:stats:total') ?: 0);

            if ($actualConnections !== $statsTotal) {
                $this->line('⚠️  警告：统计数据不一致！', 'error');
                $this->line("实际连接数: {$actualConnections}", 'comment');
                $this->line("统计值: {$statsTotal}", 'comment');
                $this->line('差异: ' . ($actualConnections - $statsTotal), 'comment');
                $this->line('');
                $this->line('建议运行修复命令：', 'info');
                $this->line('php bin/hyperf.php ws:fix-stats', 'comment');
            } else {
                $this->line('✓ 统计数据一致', 'info');
            }
        } catch (\Throwable $e) {
            $this->line('✗ 获取统计信息时发生异常：' . $e->getMessage(), 'error');
        }
    }

    private function getKeyType(Redis $redis, string $key): string
    {
        if (!$redis->exists($key)) {
            return 'not exists';
        }

        return $redis->type($key);
    }

    private function getKeySize(Redis $redis, string $key): string
    {
        if (!$redis->exists($key)) {
            return '0';
        }

        $type = $redis->type($key);
        return match ($type) {
            Redis::REDIS_HASH => (string)$redis->hLen($key),
            Redis::REDIS_SET => (string)$redis->sCard($key),
            Redis::REDIS_ZSET => (string)$redis->zCard($key),
            Redis::REDIS_LIST => (string)$redis->lLen($key),
            Redis::REDIS_STRING => '1',
            default => '?',
        };
    }

    private function countKeys(Redis $redis, string $pattern): string
    {
        $count = 0;
        $cursor = null;

        do {
            // scan() 方法通过引用参数返回新的游标，返回值是匹配的 key 数组
            $keys = $redis->scan($cursor, $pattern, 100);
            if ($keys === false) {
                break;
            }

            $count += count($keys);
        } while ($cursor !== 0 && $cursor !== null);

        return (string)$count;
    }
}
