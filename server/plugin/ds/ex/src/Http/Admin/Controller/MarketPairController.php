<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\Ex\Http\Admin\Request\MarketPairRequest as Request;
use Plugin\Ds\Ex\Http\Admin\Service\MarketPairService as Service;
use Hyperf\HttpServer\Annotation\Middleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Common\Middleware\AccessTokenMiddleware;
use App\Common\Middleware\OperationMiddleware;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\PutMapping;
use Hyperf\HttpServer\Annotation\DeleteMapping;


/**
 * 交易对数据控制器
 * 
 * @author FastApp代码生成器
 * @date 2025-12-06 12:17:05
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class MarketPairController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/ds/ex/market_pair/list')]
    #[Permission(code: 'ds:ex:market_pair:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                array_merge($this->getRequestData(), [
                    'created_by' => $this->currentUser->id(),
                ]),
                $this->getPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/ds/ex/market_pair/create')]
    #[Permission(code: 'ds:ex:market_pair:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(Request $request): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/ex/market_pair/save/{id}')]
    #[Permission(code: 'ds:ex:market_pair:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, Request $request): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/ex/market_pair/delete')]
    #[Permission(code: 'ds:ex:market_pair:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }

    /**
     * 触发进程立即刷新交易对配置
     */
    #[PostMapping(path: '/admin/ds/ex/market_pair/refresh')]
    #[Permission(code: 'ds:ex:market_pair:list')]
    public function refresh(): Result
    {
        try {
            // 1. 从数据库加载所有启用的交易对
            $pairs = \Plugin\Ds\Ex\Model\MarketPair::query()
                ->where('status', 1)
                ->orderBy('sort', 'asc')
                ->orderBy('id', 'asc')
                ->get();

            $allSymbols = [];
            $hotSymbols = [];

            foreach ($pairs as $pair) {
                $allSymbols[] = $pair->symbol;
                if ($pair->is_hot == 1) {
                    $hotSymbols[] = $pair->symbol;
                }
            }

            // 2. 写入 Redis
            $redis = \Hyperf\Context\ApplicationContext::getContainer()->get(\Hyperf\Redis\Redis::class);
            $redis->set('market:config:all_symbols', json_encode($allSymbols));
            $redis->set('market:config:hot_symbols', json_encode($hotSymbols));

            // 3. 触发进程刷新
            $redis->setex('market:ticker:refresh', 60, '1');

            return $this->success([
                'total' => count($allSymbols),
                'hot' => count($hotSymbols),
            ], '刷新成功');
        } catch (\Throwable $e) {
            return $this->error('刷新失败: ' . $e->getMessage());
        }
    }
}
