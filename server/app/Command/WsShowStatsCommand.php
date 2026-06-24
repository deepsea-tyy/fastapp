<?php
/**
 * 查看 WebSocket 连接统计的命令
 */

namespace App\Command;

use App\Websocket\Store\WsStateStoreFactory;
use App\Websocket\WsConnectionManager;
use Hyperf\Command\Annotation\Command;
use Hyperf\Command\Command as HyperfCommand;
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
        $this->setDescription('查看 WebSocket 连接统计和存储数据统计');
    }

    public function handle(): void
    {
        $store = WsStateStoreFactory::get();

        $this->line('WebSocket 连接统计信息', 'info');
        $this->line('');

        try {
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
            $this->line('存储 Key 统计信息', 'comment');
            $this->line('');

            $this->table(
                ['Key 模式', '类型', '数量/值'],
                $store->getStorageKeyStats()
            );

            $this->line('');
            $actualConnections = count($store->getAllConnectionInfos());
            $statsTotal = $store->getStatsTotal();

            if ($actualConnections != $statsTotal) {
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
}
