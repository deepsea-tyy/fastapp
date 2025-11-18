<?php

declare(strict_types=1);

namespace App\Common\Subscriber;

use Hyperf\Command\Event\AfterExecute;
use Hyperf\Database\Commands\Migrations\GenMigrateCommand;
use Hyperf\Database\Commands\Seeders\GenSeederCommand;
use Hyperf\Database\Migrations\Migrator;
use Hyperf\Database\Seeders\Seed;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Hyperf\Framework\Event\BootApplication;
use Nette\Utils\FileSystem;
use Symfony\Component\Finder\Finder;

#[Listener] // 处理程序启动
final class BootApplicationSubscriber implements ListenerInterface
{
    public function __construct(
        private readonly Migrator $migrator,
        private readonly Seed $seed
    ) {}

    public function listen(): array
    {
        return [
            BootApplication::class,
            AfterExecute::class,
        ];
    }

    public function process(object $event): void
    {
        if ($event instanceof BootApplication) {
            $this->migrator->path(BASE_PATH . '/databases/migrations');
            $this->seed->path(BASE_PATH . '/databases/seeders');
            return;
        }

        if ($event instanceof AfterExecute) {
            $command = $event->getCommand();
            $mappings = [
                GenMigrateCommand::class => ['/migrations', '/databases/migrations'],
                GenSeederCommand::class => ['/seeders', '/databases/seeders'],
            ];

            foreach ($mappings as $commandClass => [$source, $target]) {
                if ($command instanceof $commandClass && is_dir(BASE_PATH . $source)) {
                    $this->moveFiles(BASE_PATH . $source, BASE_PATH . $target);
                }
            }
        }
    }

    /**
     * 移动目录中的文件到目标目录（移动后删除源文件）
     */
    private function moveFiles(string $sourceDir, string $targetDir): void
    {
        if (!is_dir($sourceDir)) {
            return;
        }

        if (!is_dir($targetDir)) {
            Filesystem::createDir($targetDir);
        }

        $finder = Finder::create()
            ->files()
            ->in($sourceDir)
            ->ignoreDotFiles(false);

        foreach ($finder as $file) {
            $targetPath = $targetDir . '/' . $file->getRelativePathname();

            if (file_exists($targetPath)) {
                continue;
            }

            $targetFileDir = dirname($targetPath);
            if (!is_dir($targetFileDir)) {
                Filesystem::createDir($targetFileDir);
            }

            Filesystem::copy($file->getRealPath(), $targetPath);
            Filesystem::delete($file->getRealPath());
        }

        $this->removeEmptyDirectory($sourceDir);
    }

    /**
     * 删除空目录（如果目录为空）
     */
    private function removeEmptyDirectory(string $dir): void
    {
        if (!is_dir($dir)) {
            return;
        }

        $finder = Finder::create()
            ->in($dir)
            ->ignoreDotFiles(false);

        if (iterator_count($finder) === 0) {
            @rmdir($dir);
        }
    }
}
