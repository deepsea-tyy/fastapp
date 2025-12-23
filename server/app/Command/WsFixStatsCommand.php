<?php
/**
 * 修复 WebSocket 连接统计的命令
 * 手动修复统计数据不一致的问题
 */

namespace App\Command;

use App\Websocket\WsConnectionManager;
use Hyperf\Command\Annotation\Command;
use Hyperf\Command\Command as HyperfCommand;
use Psr\Container\ContainerInterface;

#[Command]
class WsFixStatsCommand extends HyperfCommand
{
    public function __construct(protected ContainerInterface $container)
    {
        parent::__construct('ws:fix-stats');
    }

    public function configure(): void
    {
        parent::configure();
        $this->setDescription('修复 WebSocket 连接统计数据（当统计值与实际连接数不一致时使用）');
    }

    public function handle(): void
    {
        $this->line('开始修复 WebSocket 连接统计...', 'info');
        $this->line('');

        try {
            $result = WsConnectionManager::fixConnectionStats();

            if ($result['fixed']) {
                $this->line('✓ 统计数据已修复！', 'info');
                $this->line('');
                $this->table(
                    ['指标', '值'],
                    [
                        ['修复前', $result['before']],
                        ['修复后', $result['after']],
                        ['差异', sprintf('%+d', $result['diff'])],
                    ]
                );
            } else {
                $this->line('✓ 统计数据正常，无需修复', 'info');
                $this->line('');
                $this->line("当前连接数: {$result['after']}", 'comment');
            }
        } catch (\Throwable $e) {
            $this->line('✗ 修复过程中发生异常：' . $e->getMessage(), 'error');
            $this->line('文件: ' . $e->getFile() . ':' . $e->getLine(), 'comment');
        }
    }
}
