<?php

declare(strict_types=1);

namespace App\Command\Plugin;

use Hyperf\Command\Annotation\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;

#[Command]
class SyncAdminCommand extends AbstractCommand
{
    protected const COMMAND_NAME = 'sync-admin';

    protected string $description = '将插件 web 目录同步到 admin（可重复执行，覆盖已有文件）';

    public function __invoke(): int
    {
        $path = $this->input->getArgument('path');
        $all = $this->input->getOption('all');

        if ($all) {
            if ($path !== null && $path !== '') {
                $this->output->error('不可同时指定 path 与 --all');
                return self::FAILURE;
            }
            $results = Plugin::syncAllInstalledAdminWeb();
            if ($results === []) {
                $this->output->warning('没有已安装且含 web 目录的插件需要同步');
                return self::SUCCESS;
            }
            $rows = [];
            foreach ($results as $rel => $count) {
                $rows[] = [$rel, (string) $count];
            }
            $this->table(['插件目录', '同步文件数'], $rows);
            $this->output->success('已全部同步到 admin');
            return self::SUCCESS;
        }

        if ($path === null || $path === '') {
            $this->output->error('请指定插件目录 path，或使用 --all 同步全部已安装插件');
            return self::FAILURE;
        }

        $count = Plugin::syncAdminWeb($path);
        $this->output->success(\sprintf('已同步 %s，共 %d 个文件', $path, $count));

        return self::SUCCESS;
    }

    protected function configure(): void
    {
        $this->addArgument('path', InputArgument::OPTIONAL, '插件目录（config.json 的相对路径，如 ds/quant）')
            ->addOption('all', 'a', InputOption::VALUE_NONE, '同步所有已安装且含 web 的插件');
    }
}
