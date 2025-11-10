<?php

declare(strict_types=1);


namespace App\Command\Plugin;

use Hyperf\Command\Annotation\Command;

#[Command]
class LocalListCommand extends AbstractCommand
{
    protected const COMMAND_NAME = 'local-list';

    protected string $description = 'List all locally installed extensions(列出本地所有已经安装的扩展)';

    public function __invoke(): int
    {
        $list = Plugin::getPluginJsonPaths();

        $headers = [
            'extensionName', 'description', 'author', 'homePage', 'status',
        ];
        $rows = [];
        foreach ($list as $splFileInfo) {
            $info = Plugin::read($splFileInfo->getRelativePath());
            $current = [
                $info['name'],
                $info['description'],
            ];
            if (\is_string($info['author'])) {
                $current[] = $info['author'];
            } else {
                $current[] = $info['author'][0]['name'] ?? '--';
            }
            $current = array_merge($current, [
                $info['homePage'] ?? '--',
                $info['status'] ? 'installed' : 'uninstalled',
            ]);
            $rows[] = $current;
        }
        $this->table($headers, $rows);
        return self::SUCCESS;
    }
}
