<?php
/**
 * 清理所有 WebSocket 连接数据的命令
 * 用于测试或手动清理所有 WebSocket 相关的 Redis 数据
 */

namespace App\Command;

use App\Websocket\WsConnectionManager;
use Hyperf\Command\Annotation\Command;
use Hyperf\Command\Command as HyperfCommand;
use Psr\Container\ContainerInterface;

#[Command]
class WsClearConnectionsCommand extends HyperfCommand
{
    public function __construct(protected ContainerInterface $container)
    {
        parent::__construct('ws:clear');
    }

    public function configure(): void
    {
        parent::configure();
        $this->setDescription('清理所有 WebSocket 连接相关的 Redis 数据（包括连接、房间、锁等）');
    }

    public function handle(): void
    {
        $this->line('开始清理所有 WebSocket 连接数据...', 'info');
        $this->line('');

        // 询问确认
        if (!$this->confirm('此操作将清理所有 WebSocket 连接、房间、锁等 Redis 数据，是否继续？')) {
            $this->line('操作已取消', 'comment');
            return;
        }

        $this->line('');
        $startTime = microtime(true);

        try {
            // 执行清理
            $result = WsConnectionManager::clearAllConnections();

            $endTime = microtime(true);
            $duration = round(($endTime - $startTime) * 1000, 2);

            if ($result['success']) {
                $this->line('✓ 清理成功！', 'info');
                $this->line('');
                $this->line('清理详情：', 'comment');
                $this->table(
                    ['类型', '数量'],
                    [
                        ['连接信息 (connections_info)', $result['details']['connections_info'] ?? 0],
                        ['总连接统计 (stats_total)', empty($result['details']['stats_total']) ? '-' : '✓'],
                        ['用户→FD映射 (user_fds_mappings)', $result['details']['user_fds_mappings'] ?? 0],
                        ['FD→用户映射 (fd_user_mappings)', $result['details']['fd_user_mappings'] ?? 0],
                        ['分布式锁 (locks)', $result['details']['locks'] ?? 0],
                        ['房间FD数据 (room_fds)', $result['details']['room_fds'] ?? 0],
                        ['房间用户数据 (room_users)', $result['details']['room_users'] ?? 0],
                        ['FD房间列表 (fd_rooms)', $result['details']['fd_rooms'] ?? 0],
                    ]
                );
                $this->line('');
                $this->line("总计清理 {$result['cleared_keys']} 个 Redis key", 'info');
                $this->line("耗时: {$duration} ms", 'comment');
            } else {
                $this->line('✗ 清理失败：' . ($result['error'] ?? '未知错误'), 'error');
                $this->line("已清理 {$result['cleared_keys']} 个 key 后发生错误", 'comment');
            }
        } catch (\Throwable $e) {
            $this->line('✗ 清理过程中发生异常：' . $e->getMessage(), 'error');
            $this->line('文件: ' . $e->getFile() . ':' . $e->getLine(), 'comment');
        }
    }
}
