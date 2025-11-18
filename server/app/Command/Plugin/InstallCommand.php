<?php

declare(strict_types=1);


namespace App\Command\Plugin;

use Hyperf\Command\Annotation\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;

#[Command]
class InstallCommand extends AbstractCommand
{
    protected const COMMAND_NAME = 'install';

    protected string $description = 'Installing Plugin Commands';

    public function __invoke(): int
    {
        $path = $this->input->getArgument('path');
        $yes = $this->input->getOption('yes');
        $info = Plugin::read($path);

        $headers = ['Extension name', 'author', 'description', 'homepage'];
        $rows[] = [
            $info['name'],
            \is_string($info['author']) ? $info['author'] : ($info['author'][0]['name'] ?? '--'),
            $info['description'],
            $info['homepage'] ?? '--',
        ];
        $this->table($headers, $rows);
        $confirm = $yes ?: $this->confirm('Enter to start the installation', true);
        if (! $confirm) {
            $this->output->success('Installation has been successfully canceled');
            return self::SUCCESS;
        }
        Plugin::install($path);
        $this->output->success(\sprintf('Plugin %s installed successfully', $path));
        return self::SUCCESS;
    }

    protected function configure(): void
    {
        $this->addArgument('path', InputArgument::REQUIRED, 'Plug-in Catalog (relative path)')
            ->addOption('yes', 'y', InputOption::VALUE_NONE, 'silent installation');
    }
}
