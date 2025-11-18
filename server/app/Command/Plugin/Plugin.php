<?php

declare(strict_types=1);


namespace App\Command\Plugin;

use App\Command\Plugin\Packer\PackerFactory;
use App\Command\Plugin\Packer\PackerInterface;
use Composer\InstalledVersions;
use Hyperf\Config\ProviderConfig;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Context\ApplicationContext;
use Hyperf\Database\Migrations\Migrator;
use Hyperf\Database\Seeders\Seed;
use Hyperf\Di\Definition\PriorityDefinition;
use Hyperf\Support\Composer;
use Swoole\Coroutine\System;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Finder\SplFileInfo;

class Plugin
{
    /**
     * File flags for successful plugin installation.
     */
    public const INSTALL_LOCK_FILE = 'install.lock';

    /**
     * Plugin root directory.
     */
    public const PLUGIN_PATH = BASE_PATH . '/' . self::PLUGIN_PREFIX;

    public const PLUGIN_PREFIX = 'plugin';

    private static array $configJsonPaths = [];

    private static array $pluginConfigProviders = [];

    public static function getPacker(): PackerInterface
    {
        return (new PackerFactory())->get();
    }

    public static function init(): void
    {
        $configJsons = self::getPluginJsonPaths();

        foreach ($configJsons as $config) {
            $info = self::read($config->getRelativePath());
            $installLockFile = $config->getPath() . '/' . self::INSTALL_LOCK_FILE;

            if (file_exists($installLockFile)) {
                self::loadPlugin($info, $config);
                self::registerConfigProvider($info);
            }
        }

        self::injectProviderConfig();
    }

    /**
     * Get information about all local plugins.
     * @return SplFileInfo[]
     */
    public static function getPluginJsonPaths(): array
    {
        if (self::$configJsonPaths) {
            return self::$configJsonPaths;
        }
        
        if (!is_dir(self::PLUGIN_PATH)) {
            return [];
        }
        
        $configs = Finder::create()
            ->in(self::PLUGIN_PATH)
            ->name('config.json')
            ->sortByChangedTime();
        foreach ($configs as $jsonFile) {
            self::$configJsonPaths[] = $jsonFile;
        }
        return self::$configJsonPaths;
    }

    /**
     * Query plugin information based on a given catalog.
     * @return array<string,mixed>
     * @throws PluginNotFoundException
     */
    public static function read(string $path): array
    {
        $jsonPaths = self::getPluginJsonPaths();
        foreach ($jsonPaths as $jsonPath) {
            if ($jsonPath->getRelativePath() === $path) {
                $jsonContent = @file_get_contents($jsonPath->getRealPath());
                if ($jsonContent === false) {
                    throw new \RuntimeException(\sprintf('Failed to read plugin config file: %s', $jsonPath->getRealPath()));
                }
                $info = self::getPacker()->unpack($jsonContent);
                $info['status'] = is_file($jsonPath->getPath() . '/' . self::INSTALL_LOCK_FILE);
                return $info;
            }
        }
        throw new PluginNotFoundException($path);
    }

    /**
     * @throws PluginNotFoundException
     */
    public static function getSplFile(string $path): SplFileInfo
    {
        $jsonPaths = self::getPluginJsonPaths();
        foreach ($jsonPaths as $jsonPath) {
            if ($jsonPath->getRelativePath() === $path) {
                return $jsonPath;
            }
        }
        throw new PluginNotFoundException($path);
    }

    /**
     * Detects if the given plugin exists and is installed.
     */
    public static function exists(string $name): bool
    {
        $jsonPaths = self::getPluginJsonPaths();
        foreach ($jsonPaths as $jsonPath) {
            $info = self::read($jsonPath->getRelativePath());
            if ($info['name'] === $name) {
                return true;
            }
        }
        return false;
    }

    public static function forceRefreshJsonPath(): void
    {
        self::$configJsonPaths = [];
    }

    /**
     * Install the plugin according to the given directory.
     */
    public static function install(string $path): void
    {
        $info = self::read($path);
        $splFile = self::getSplFile($path);

        self::loadPlugin($info, $splFile);
        $pluginPath = self::PLUGIN_PATH . '/' . $path;
        if ($info['status']) {
            throw new \RuntimeException(
                'The given directory detects an installation and terminates the installation operation'
            );
        }
        // Performs a check on plugin dependencies. Determine if the plugin also depends on other plugins
        if (!empty($info['require']) && !\is_array($info['require'])) {
            throw new \RuntimeException('Plugin dependency format error');
        }
        if (!empty($info['require'])) {
            $pluginRequires = $info['require'];
            foreach ($pluginRequires as $require) {
                if (!self::exists($require)) {
                    throw new \RuntimeException(
                        \sprintf(
                            'Plugin %s depends on plugin %s, but the dependency is not installed',
                            $info['name'],
                            $require
                        )
                    );
                }
            }
        }
        // Handling composer dependencies
        if (!empty($info['composer']['require'])) {
            self::handleComposerDependencies($info['composer']['require'], true);
        }

        if (!empty($info['composer']['installScript']) && class_exists($installScript = $info['composer']['installScript'])) {
            $installScript = ApplicationContext::getContainer()->make($installScript);
            $installScript();
        }

        // Run composer scripts
        if (!empty($info['composer']['script'])) {
            self::executeComposerScripts($info['composer']['script']);
        }

        // Handling front-end dependencies
        if (!empty($info['package']['dependencies'])) {
            self::handleFrontendDependencies($info['package']['dependencies'], $info['name'], true);
        }

        // Handling database migration
        $migrator = ApplicationContext::getContainer()->get(Migrator::class);
        $seeder = ApplicationContext::getContainer()->get(Seed::class);

        // Perform migration
        $migrator->run($pluginPath . '/Database/Migrations');
        // Perform Data Filling
        $seeder->run($pluginPath . '/Database/Seeders');
        
        // If the plugin exists in the web directory, perform the migration of the front-end files
        $frontDirectory = self::getConfig('front_directory', BASE_PATH . '/web');
        if (file_exists($pluginPath . '/web')) {
            $finder = Finder::create()
                ->files()
                ->in($pluginPath . '/web');
            foreach ($finder as $file) {
                /**
                 * @var SplFileInfo $file
                 */
                $relativeFilePath = $file->getRelativePathname();
                FileSystemUtils::copy($pluginPath . '/web/' . $relativeFilePath, $frontDirectory . '/src/plugins/' . $path . \DIRECTORY_SEPARATOR . $relativeFilePath);
            }
        }

        $lockFile = $pluginPath . '/' . self::INSTALL_LOCK_FILE;
        if (file_put_contents($lockFile, '1') === false) {
            throw new \RuntimeException(\sprintf('Failed to create install lock file: %s', $lockFile));
        }

        // check is run publish command
        if (!empty($info['composer']['config'])) {
            $composerConfig = (new $info['composer']['config']())();
            if (!empty($composerConfig['publish'])) {
                $result = System::exec(\sprintf('cd %s && php bin/hyperf.php plugin:script %s', BASE_PATH, $path));
                if ($result['code'] !== 0) {
                    throw new \RuntimeException(\sprintf('Failed to run plugin script, details: %s', $result['output'] ?? '--'));
                }
            }
        }

        // remove cache
        System::exec(\sprintf('rm -rf %s', BASE_PATH . \DIRECTORY_SEPARATOR . 'runtime/container'));
    }

    public static function uninstall(string $path): void
    {
        $info = self::read($path);
        $pluginPath = self::PLUGIN_PATH . '/' . $path;
        if (!$info['status']) {
            throw new \RuntimeException(
                'No installation behavior was detected for this plugin, and uninstallation could not be performed'
            );
        }
        if (!empty($info['composer']['require'])) {
            self::handleComposerDependencies($info['composer']['require'], false);
        }

        if (!empty($info['composer']['uninstallScript']) && class_exists($info['composer']['uninstallScript'])) {
            $uninstallScript = ApplicationContext::getContainer()->make($info['composer']['uninstallScript']);
            $uninstallScript();
        }

        // Handling front-end dependencies
        if (!empty($info['package']['dependencies'])) {
            self::handleFrontendDependencies($info['package']['dependencies'], $info['name'], false);
        }

        // Handling database migration
        $migrator = ApplicationContext::getContainer()->get(Migrator::class);

        // Perform migration rollback
        $migrator->rollback($pluginPath . '/Database/Migrations');
        
        // If the plugin exists in the web directory, perform the migration of the front-end files
        $frontDirectory = self::getConfig('front_directory', BASE_PATH . '/web');
        if (file_exists($pluginPath . '/web')) {
            $finder = Finder::create()
                ->files()
                ->in($pluginPath . '/web');
            foreach ($finder as $file) {
                /**
                 * @var SplFileInfo $file
                 */
                $relativeFilePath = $file->getRelativePathname();
                FileSystemUtils::recovery($relativeFilePath, $frontDirectory);
            }
        }

        $lockFile = $pluginPath . '/' . self::INSTALL_LOCK_FILE;
        if (file_exists($lockFile) && !unlink($lockFile)) {
            throw new \RuntimeException(\sprintf('Failed to remove install lock file: %s', $lockFile));
        }
    }

    public static function getConfig(string $key, mixed $default = null): mixed
    {
        $container = ApplicationContext::getContainer();
        $config = $container->get(ConfigInterface::class);
        $configKey = 'plugin.' . $key;
        return $config->get($configKey, $default);
    }

    private static function loadPlugin(array $info, SplFileInfo $config): void
    {
        $loader = Composer::getLoader();
        // psr-4
        if (!empty($info['composer']['psr-4'])) {
            foreach ($info['composer']['psr-4'] as $namespace => $src) {
                $srcPath = realpath($config->getPath() . '/' . $src);
                if ($srcPath === false || !is_dir($srcPath)) {
                    throw new \RuntimeException(\sprintf('Invalid PSR-4 path for namespace %s: %s', $namespace, $src));
                }
                $loader->addPsr4($namespace, $srcPath);
            }
        }

        // files
        if (!empty($info['composer']['files'])) {
            foreach ($info['composer']['files'] as $file) {
                $filePath = $config->getPath() . '/' . $file;
                if (!file_exists($filePath)) {
                    throw new \RuntimeException(\sprintf('Plugin file not found: %s', $filePath));
                }
                require_once $filePath;
            }
        }

        // classMap
        if (!empty($info['composer']['classMap'])) {
            $loader->addClassMap($info['composer']['classMap']);
        }
    }

    /**
     * Register plugin ConfigProvider class for later loading
     */
    private static function registerConfigProvider(array $info): void
    {
        $configProviderClass = $info['composer']['config'] ?? null;
        if (empty($configProviderClass) || !is_string($configProviderClass)) {
            return;
        }

        if (!class_exists($configProviderClass) || !method_exists($configProviderClass, '__invoke')) {
            return;
        }

        self::$pluginConfigProviders[] = $configProviderClass;
    }

    /**
     * Inject plugin configs into ProviderConfig cache
     * This ensures ScanConfig and other components that call ProviderConfig::load()
     * will automatically get plugin configs merged in
     */
    private static function injectProviderConfig(): void
    {
        $mergedConfigs = self::loadProviderConfig();
        $reflection = new \ReflectionClass(ProviderConfig::class);
        $property = $reflection->getProperty('providerConfigs');
        $property->setAccessible(true);
        $property->setValue(null, $mergedConfigs);
    }

    /**
     * Get all plugin ConfigProvider classes
     * This method is called by ProviderConfig extension
     */
    public static function getPluginConfigProviders(): array
    {
        return self::$pluginConfigProviders;
    }

    /**
     * Load and merge all plugin configs
     */
    public static function loadPluginConfigs(): array
    {
        $pluginConfigs = [];
        foreach (self::$pluginConfigProviders as $configProviderClass) {
            try {
                if (!class_exists($configProviderClass) || !method_exists($configProviderClass, '__invoke')) {
                    continue;
                }
                $configProvider = new $configProviderClass();
                $config = $configProvider();
                if (is_array($config)) {
                    $pluginConfigs[] = $config;
                }
            } catch (\Throwable $e) {
                // Silently ignore errors during plugin config loading
            }
        }
        return $pluginConfigs;
    }

    /**
     * Load and merge all provider configs from components and plugins.
     * This method extends ProviderConfig::load() to include plugin configs.
     */
    public static function loadProviderConfig(): array
    {
        // Load standard provider configs first
        $configs = ProviderConfig::load();
        
        // Load plugin configs and merge
        $pluginConfigs = self::loadPluginConfigs();
        if (!empty($pluginConfigs)) {
            $configs = self::mergePluginConfigs($configs, $pluginConfigs);
        }
        
        return $configs;
    }

    /**
     * Merge plugin configs with existing configs
     */
    private static function mergePluginConfigs(array $existing, array $pluginConfigs): array
    {
        $result = $existing;
        
        foreach ($pluginConfigs as $pluginConfig) {
            $result = array_merge_recursive($result, $pluginConfig);
        }
        
        // Handle dependencies specially (similar to ProviderConfig::merge)
        if (isset($result['dependencies'])) {
            $mergedDependencies = [];
            $allConfigs = array_merge([$existing], $pluginConfigs);
            
            foreach ($allConfigs as $config) {
                foreach ($config['dependencies'] ?? [] as $key => $value) {
                    $depend = $mergedDependencies[$key] ?? null;
                    if (! $depend instanceof PriorityDefinition) {
                        $mergedDependencies[$key] = $value;
                        continue;
                    }

                    if ($value instanceof PriorityDefinition) {
                        $depend->merge($value);
                    }
                }
            }
            
            $result['dependencies'] = $mergedDependencies;
        }
        
        return $result;
    }

    /**
     * Handle composer dependencies (install or remove)
     */
    private static function handleComposerDependencies(array $requires, bool $install): void
    {
        $composerBin = self::getConfig('composer.bin', 'composer');
        $checkResult = System::exec(\sprintf('%s --version', $composerBin));
        if (($checkResult['code'] ?? 0) !== 0) {
            throw new \RuntimeException(\sprintf('Composer command error, details: %s', $checkResult['output'] ?? '--'));
        }

        $commands = [\sprintf('cd %s', BASE_PATH)];

        if ($install) {
            $packageList = [];
            foreach ($requires as $package => $version) {
                if (!InstalledVersions::isInstalled($package)) {
                    $packageList[] = \sprintf('%s:%s', $package, $version);
                }
            }
            if (!empty($packageList)) {
                $commands[] = \sprintf('%s require %s', $composerBin, implode(' ', $packageList));
            }
        } else {
            foreach ($requires as $package => $version) {
                if (InstalledVersions::isInstalled($package)) {
                    $commands[] = \sprintf('%s remove %s', $composerBin, $package);
                }
            }
        }

        foreach ($commands as $cmd) {
            $result = System::exec($cmd);
            if ($result['code'] !== 0) {
                $action = $install ? 'install' : 'remove';
                throw new \RuntimeException(\sprintf('Failed to %s composer dependencies, details: %s', $action, $result['output'] ?? '--'));
            }
        }
    }

    /**
     * Execute composer scripts
     */
    private static function executeComposerScripts(array $scripts): void
    {
        $baseCmd = \sprintf('cd %s &&', BASE_PATH);
        foreach ($scripts as $name => $script) {
            $result = System::exec(\sprintf('%s %s', $baseCmd, $script));
            if ($result['code'] !== 0) {
                throw new \RuntimeException(\sprintf('Failed to execute composer script "%s", details: %s', $name, $result['output'] ?? '--'));
            }
        }
    }

    /**
     * Handle frontend dependencies (install or remove)
     */
    private static function handleFrontendDependencies(array $dependencies, string $pluginName, bool $install): void
    {
        $frontDirectory = self::getConfig('front_directory', BASE_PATH . '/web');
        $packageJsonPath = $frontDirectory . '/package.json';

        if (!file_exists($packageJsonPath)) {
            throw new \RuntimeException(\sprintf('Frontend package.json not found at %s', $packageJsonPath));
        }

        $packageJsonContent = @file_get_contents($packageJsonPath);
        if ($packageJsonContent === false) {
            throw new \RuntimeException(\sprintf('Failed to read package.json: %s', $packageJsonPath));
        }
        $packageJson = self::getPacker()->unpack($packageJsonContent);
        $frontDependencies = array_keys($packageJson['dependencies'] ?? []);

        $frontBin = self::getConfig('front-tool');
        $type = $frontBin['type'] ?? 'npm';
        $bin = $frontBin['bin'] ?? 'npm';

        // Check frontend tool availability
        $checkResult = System::exec(\sprintf('%s --version', $type));
        if ($checkResult['code'] !== 0) {
            throw new \RuntimeException(\sprintf('Frontend tool "%s" not available, details: %s', $type, $checkResult['output'] ?? '--'));
        }

        $command = match ($type) {
            'npm', 'pnpm' => $install ? 'install' : 'uninstall',
            'yarn' => $install ? 'add' : 'remove',
            default => null
        };

        if ($command === null) {
            throw new \RuntimeException('Frontend tool type must be one of: npm, pnpm, yarn');
        }

        // Validate dependencies first
        foreach ($dependencies as $package => $version) {
            if ($install) {
                if (\in_array($package, $frontDependencies, true)) {
                    throw new \RuntimeException(\sprintf('Plugin %s depends on %s, but it already exists in the project', $pluginName, $package));
                }
            } else {
                if (!\in_array($package, $frontDependencies, true)) {
                    throw new \RuntimeException(\sprintf('Plugin %s depends on %s, but it is not found in the project', $pluginName, $package));
                }
            }
        }

        // Build command with all packages
        if (empty($dependencies)) {
            return; // No dependencies to install/remove
        }

        $cmdBody = \sprintf('cd %s && %s %s', $frontDirectory, $bin, $command);
        foreach ($dependencies as $package => $version) {
            $cmdBody .= \sprintf(' %s@%s', $package, $version);
        }

        $result = System::exec($cmdBody);
        if ($result['code'] !== 0) {
            $action = $install ? 'install' : 'remove';
            throw new \RuntimeException(\sprintf('Failed to %s frontend dependencies, details: %s', $action, $result['output'] ?? '--'));
        }
    }
}
