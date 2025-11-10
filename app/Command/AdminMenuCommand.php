<?php

declare(strict_types=1);

namespace App\Command;

use App\Model\Permission\Menu;
use Hyperf\Command\Annotation\AsCommand;
use Hyperf\Command\Command;
use Hyperf\Context\ApplicationContext;
use Hyperf\DbConnection\Db;
use Symfony\Component\Finder\Finder;

#[AsCommand(
    signature: 'admin:menu',
    description: '更新插件databases目录和插件目录中的所有menu开头的Seeders文件',
)]
class AdminMenuCommand extends Command
{
    /**
     * 菜单缓存：parent_id => [name => Menu]
     */
    private array $menuCache = [];

    public function handle(): int
    {
        $this->info('开始更新菜单 Seeders...');

        $seederFiles = $this->findMenuSeederFiles();

        if (empty($seederFiles)) {
            $this->warn('未找到任何 menu 开头的 Seeder 文件');
            return self::SUCCESS;
        }

        $this->info("找到 " . count($seederFiles) . " 个 Seeder 文件");

        $successCount = 0;
        $failCount = 0;

        foreach ($seederFiles as $filePath) {
            try {
                $this->runSeederFile($filePath);
                $successCount++;
                $this->info("✓ 执行成功: " . basename($filePath));
            } catch (\Throwable $e) {
                $failCount++;
                $this->error("✗ 执行失败: " . basename($filePath));
                $this->error("  错误信息: " . $e->getMessage());
                if ($this->output->isVerbose()) {
                    $this->error("  文件路径: {$filePath}");
                    $this->error("  堆栈跟踪: " . $e->getTraceAsString());
                }
            }
        }

        $this->info("\n更新完成!");
        $this->info("成功: {$successCount} 个");
        if ($failCount > 0) {
            $this->error("失败: {$failCount} 个");
        }

        return $failCount > 0 ? self::FAILURE : self::SUCCESS;
    }

    /**
     * 查找所有 menu 开头的 Seeder 文件
     *
     * @return array<string>
     */
    private function findMenuSeederFiles(): array
    {
        $files = [];

        // 扫描路径列表
        $scanPaths = [
            BASE_PATH . '/databases/seeders',
        ];

        // 扫描插件目录下的所有 Database/Seeders 目录
        $pluginPath = BASE_PATH . '/plugin';
        if (is_dir($pluginPath)) {
            $finder = Finder::create()
                ->directories()
                ->name('Seeders')
                ->path('Database/Seeders')
                ->in($pluginPath)
                ->depth('>=2');

            foreach ($finder as $seedersDir) {
                $scanPaths[] = $seedersDir->getRealPath();
            }
        }

        // 统一扫描所有路径
        foreach ($scanPaths as $path) {
            if (!is_dir($path)) {
                continue;
            }

            $finder = Finder::create()
                ->files()
                ->name('menu*.php')
                ->in($path);

            foreach ($finder as $file) {
                $files[] = $file->getRealPath();
            }
        }

        return $files;
    }

    /**
     * 执行 Seeder 文件
     *
     * @param string $filePath Seeder 文件路径
     * @throws \RuntimeException
     */
    private function runSeederFile(string $filePath): void
    {
        // 解析文件获取类信息
        $classInfo = $this->parseSeederFile($filePath);

        // 加载文件
        require_once $filePath;

        // 验证类
        $this->validateSeederClass($classInfo['fullClassName']);

        // 实例化并执行
        $seederInstance = ApplicationContext::getContainer()->get($classInfo['fullClassName']);
        $reflection = new \ReflectionClass($classInfo['fullClassName']);

        // 获取基础数据和菜单数据
        $baseData = $this->getBaseData($reflection);
        $menuData = $this->getMenuData($seederInstance, $classInfo['fullClassName']);

        // 处理 SQL Server 的特殊情况
        $isSqlServer = env('DB_DRIVER') === 'odbc-sql-server';
        if ($isSqlServer) {
            Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] ON;');
        }

        try {
            // 清空缓存
            $this->menuCache = [];
            
            // 使用支持更新的 create 方法
            $this->createOrUpdate($menuData, 0, $baseData);
        } finally {
            if ($isSqlServer) {
                Db::unprepared('SET IDENTITY_INSERT [' . Menu::getModel()->getTable() . '] OFF;');
            }
        }
    }

    /**
     * 解析 Seeder 文件，提取类名和命名空间
     *
     * @param string $filePath 文件路径
     * @return array{namespace: ?string, className: string, fullClassName: string}
     * @throws \RuntimeException
     */
    private function parseSeederFile(string $filePath): array
    {
        $content = file_get_contents($filePath);
        if (!$content) {
            throw new \RuntimeException("无法读取文件: {$filePath}");
        }

        // 提取命名空间
        $namespace = null;
        if (preg_match('/namespace\s+([^;]+);/', $content, $matches)) {
            $namespace = trim($matches[1]);
        }

        // 提取类名
        if (!preg_match('/class\s+(\w+)/', $content, $matches)) {
            throw new \RuntimeException("无法从文件中提取类名: {$filePath}");
        }

        $className = $matches[1];
        $fullClassName = $namespace ? $namespace . '\\' . $className : $className;

        return [
            'namespace' => $namespace,
            'className' => $className,
            'fullClassName' => $fullClassName,
        ];
    }

    /**
     * 验证 Seeder 类
     *
     * @param string $fullClassName 完整类名
     * @throws \RuntimeException
     */
    private function validateSeederClass(string $fullClassName): void
    {
        if (!class_exists($fullClassName)) {
            throw new \RuntimeException("类不存在: {$fullClassName}");
        }

        $reflection = new \ReflectionClass($fullClassName);
        if (!$reflection->isSubclassOf(\Hyperf\Database\Seeders\Seeder::class)) {
            throw new \RuntimeException("类 {$fullClassName} 不是 Seeder 的子类");
        }
    }

    /**
     * 获取 BASE_DATA 常量
     *
     * @param \ReflectionClass $reflection 反射类
     * @return array
     */
    private function getBaseData(\ReflectionClass $reflection): array
    {
        if ($reflection->hasConstant('BASE_DATA')) {
            return $reflection->getConstant('BASE_DATA') ?? [];
        }
        return [];
    }

    /**
     * 获取菜单数据
     *
     * @param object $seederInstance Seeder 实例
     * @param string $fullClassName 完整类名
     * @return array
     * @throws \RuntimeException
     */
    private function getMenuData(object $seederInstance, string $fullClassName): array
    {
        if (!method_exists($seederInstance, 'data')) {
            throw new \RuntimeException("Seeder 类没有 data 方法: {$fullClassName}");
        }

        return $seederInstance->data();
    }

    /**
     * 创建或更新菜单（支持更新已存在的菜单）
     *
     * @param array $data 菜单数据
     * @param int $parentId 父菜单ID
     * @param array $baseData 基础数据
     */
    private function createOrUpdate(array $data, int $parentId = 0, array $baseData = []): void
    {
        foreach ($data as $menuItem) {
            // 分离子菜单数据
            $children = $menuItem['children'] ?? null;
            unset($menuItem['children']);

            // 准备菜单数据
            $menuData = array_merge($baseData, $menuItem, ['parent_id' => $parentId]);

            // 查找或创建菜单
            $menu = $this->findOrCreateMenu($menuData);

            // 递归处理子菜单
            if ($children && count($children) > 0) {
                $this->createOrUpdate($children, $menu->id, $baseData);
            }
        }
    }

    /**
     * 查找或创建菜单
     *
     * @param array $menuData 菜单数据
     * @return Menu
     */
    private function findOrCreateMenu(array $menuData): Menu
    {
        $menuName = $menuData['name'] ?? null;
        $parentId = $menuData['parent_id'] ?? 0;

        // 如果没有 name，直接创建
        if (!$menuName) {
            return Menu::create($menuData);
        }

        // 从缓存中查找
        $menu = $this->getMenuFromCache($menuName, $parentId);

        if ($menu) {
            // 更新现有菜单
            $updateData = $menuData;
            unset($updateData['created_by']); // 保留原有的创建者
            $menu->update($updateData);
            return $menu;
        }

        // 创建新菜单
        $menu = Menu::create($menuData);
        
        // 添加到缓存
        $this->addMenuToCache($menu, $parentId);

        return $menu;
    }

    /**
     * 从缓存中获取菜单
     *
     * @param string $menuName 菜单名称
     * @param int $parentId 父菜单ID
     * @return Menu|null
     */
    private function getMenuFromCache(string $menuName, int $parentId): ?Menu
    {
        // 如果缓存中没有该父级的数据，先加载
        if (!isset($this->menuCache[$parentId])) {
            $this->loadMenusByParentId($parentId);
        }

        return $this->menuCache[$parentId][$menuName] ?? null;
    }

    /**
     * 加载指定父级的所有菜单到缓存
     *
     * @param int $parentId 父菜单ID
     */
    private function loadMenusByParentId(int $parentId): void
    {
        $menus = Menu::query()
            ->where('parent_id', $parentId)
            ->get();

        $this->menuCache[$parentId] = [];
        foreach ($menus as $menu) {
            if ($menu->name) {
                $this->menuCache[$parentId][$menu->name] = $menu;
            }
        }
    }

    /**
     * 将菜单添加到缓存
     *
     * @param Menu $menu 菜单对象
     * @param int $parentId 父菜单ID
     */
    private function addMenuToCache(Menu $menu, int $parentId): void
    {
        if (!isset($this->menuCache[$parentId])) {
            $this->menuCache[$parentId] = [];
        }

        if ($menu->name) {
            $this->menuCache[$parentId][$menu->name] = $menu;
        }
    }
}
