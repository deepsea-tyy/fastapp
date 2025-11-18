<?php

declare(strict_types=1);


namespace App\Command\Plugin;

use Hyperf\Codec\Json;
use Hyperf\Command\Annotation\Command;
use Hyperf\Stringable\Str;
use Symfony\Component\Console\Command\Command as CommandAlias;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;

#[Command]
class CreateCommand extends AbstractCommand
{
    protected const COMMAND_NAME = 'create';

    protected string $description = 'Creating Plug-ins';

    public function __invoke(): int
    {
        $path = $this->input->getArgument('path');
        $name = $this->input->getOption('name') ?? '';
        $type = $this->input->getOption('type') ?? 'mix';
        $type = PluginTypeEnum::fromValue($type);
        if ($type === null) {
            $this->output->error('Plugin type is empty');
            return CommandAlias::FAILURE;
        }

        $pluginPath = Plugin::PLUGIN_PATH . '/' . $path;
        if (file_exists($pluginPath)) {
            $this->output->error(\sprintf('Plugin directory %s already exists', $path));
            return CommandAlias::FAILURE;
        }
        $createDirectors = [
            $pluginPath,
            $pluginPath . '/src',
            $pluginPath . '/src/Http',
            $pluginPath . '/src/Model',
            $pluginPath . '/src/Repository',
            $pluginPath . '/src/Service',
            $pluginPath . '/Database',
            $pluginPath . '/Database/Migrations',
            $pluginPath . '/Database/Seeders',
            $pluginPath . '/web',
        ];
        foreach ($createDirectors as $directory) {
            if (!mkdir($directory, 0o755, true) && !is_dir($directory)) {
                throw new \RuntimeException(\sprintf('Directory "%s" was not created', $directory));
            }
        }

        $this->createConfigJson($pluginPath, $name, $type);
        return CommandAlias::SUCCESS;
    }

    public function createNamespace(string $path): string
    {
        // 移除插件根路径前缀，获取相对路径（如：ds/message-notify）
        $pluginPath = Str::replace(Plugin::PLUGIN_PATH . '/', '', $path);
        $pluginPath = Str::replace(Plugin::PLUGIN_PATH . '\\', '', $pluginPath);
        
        // 分割路径，移除空元素
        $parts = array_filter(explode('/', $pluginPath));
        $parts = array_values($parts); // 重新索引数组
        
        if (count($parts) < 2) {
            throw new \RuntimeException(\sprintf('Invalid plugin path: %s, expected format: org/plugin-name', $pluginPath));
        }
        
        // 取组织名和插件名（支持多级路径，但只取最后两级）
        $orgName = $parts[0];
        $pluginName = $parts[count($parts) - 1]; // 取最后一部分作为插件名
        
        return 'Plugin\\' . Str::studly($orgName) . '\\' . Str::studly($pluginName);
    }

    public function createConfigJson(string $path, string $name, PluginTypeEnum $pluginType): void
    {
        // 移除插件根路径前缀，获取相对路径（如：ds/message-notify）
        $pluginPath = Str::replace(Plugin::PLUGIN_PATH . '/', '', $path);
        $pluginPath = Str::replace(Plugin::PLUGIN_PATH . '\\', '', $pluginPath);
        // 移除前导斜杠（处理绝对路径情况）
        $pluginPath = ltrim($pluginPath, '/\\');
        
        // 如果提供了 name 选项，优先使用；否则使用路径
        $output = new \stdClass();
        $output->name = !empty($name) ? $name : $pluginPath;
        $output->version = '1.0.0';
        $output->type = $pluginType->value;
        $output->description = $this->input->getOption('description') ?: 'This is a sample plugin';
        $author = $this->input->getOption('author') ?: '';
        $output->author = [
            [
                'name' => $author,
            ],
        ];
        if ($pluginType === PluginTypeEnum::Backend || $pluginType === PluginTypeEnum::Mix) {
            $namespace = $this->createNamespace($path);

            $this->createInstallScript($namespace, $path);
            $this->createUninstallScript($namespace, $path);
            $this->createConfigProvider($namespace, $path);
            $output->composer = [
                'require' => [],
                'psr-4' => [
                    $namespace . '\\' => 'src',
                ],
                'installScript' => $namespace . '\\InstallScript',
                'uninstallScript' => $namespace . '\\UninstallScript',
                'config' => $namespace . '\\ConfigProvider',
            ];
        }

        if ($pluginType === PluginTypeEnum::Mix || $pluginType === PluginTypeEnum::Frond) {
            $output->package = [
                'dependencies' => [],
            ];
        }
        $output = Json::encode($output);
        file_put_contents($path . '/config.json', $output);
        $this->output->success(\sprintf('%s 创建成功', $path . '/config.json'));
    }

    public function createInstallScript(string $namespace, string $path): void
    {
        $installScript = $this->buildStub('InstallScript', compact('namespace'));
        $installScriptPath = $path . '/src/InstallScript.php';
        file_put_contents($installScriptPath, $installScript);
        $this->output->success(\sprintf('%s Created Successfully', $installScriptPath));
    }

    public function buildStub(string $stub, array $replace): string
    {
        $stubPath = __DIR__ . '/Stub/' . $stub . '.stub';
        if (!file_exists($stubPath)) {
            throw new \RuntimeException(\sprintf('File %s does not exist', $stubPath));
        }
        $stubBody = file_get_contents($stubPath);
        foreach ($replace as $key => $value) {
            $stubBody = str_replace('%' . $key . '%', $value, $stubBody);
        }
        return $stubBody;
    }

    public function createUninstallScript(string $namespace, string $path): void
    {
        $uninstallScript = $this->buildStub('UninstallScript', compact('namespace'));
        $uninstallScriptPath = $path . '/src/UninstallScript.php';
        file_put_contents($uninstallScriptPath, $uninstallScript);
        $this->output->success(\sprintf('%s Created Successfully', $uninstallScriptPath));
    }

    public function createConfigProvider(string $namespace, string $path): void
    {
        $installScript = $this->buildStub('ConfigProvider', compact('namespace'));
        $installScriptPath = $path . '/src/ConfigProvider.php';
        file_put_contents($installScriptPath, $installScript);
        $this->output->success(\sprintf('%s Created Successfully', $installScriptPath));
    }

    protected function configure(): void
    {
        $this->addArgument('path', InputArgument::REQUIRED, 'Plugin Path')
            ->addOption('name', 'name', InputOption::VALUE_REQUIRED, 'Plug-in Name')
            ->addOption('type', 'type', InputOption::VALUE_OPTIONAL, 'Plugin type, default mix optional mix,frond,backend')
            ->addOption('description', 'desc', InputOption::VALUE_OPTIONAL, 'Plug-in Introduction')
            ->addOption('author', 'author', InputOption::VALUE_OPTIONAL, 'Plugin Author Information');
    }
}
