<?php

declare(strict_types=1);
namespace Plugin\Ds\Ex\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use App\Http\CurrentUser;
use Plugin\Ds\Ex\Http\Admin\Request\CurrencyRequest as Request;
use Plugin\Ds\Ex\Http\Admin\Service\CurrencyService as Service;
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
 * 币种信息控制器
 *
 * @author FastApp代码生成器
 * @date 2025-12-06 12:06:31
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class CurrencyController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly CurrentUser $currentUser
    ) {}

    #[GetMapping(path: '/admin/ds/ex/currency/list')]
    #[Permission(code: 'ds:ex:currency:list')]
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

    #[GetMapping(path: '/admin/ds/ex/currency/selectCurrency')]
    #[Permission(code: 'ds:ex:currency:list')]
    public function selectCurrency(): Result
    {
        return $this->success(
            $this->service->selectCurrency($this->getRequestData())
        );
    }

    #[PostMapping(path: '/admin/ds/ex/currency/create')]
    #[Permission(code: 'ds:ex:currency:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function create(): Result
    {
        $this->service->create(array_merge($this->getRequestData(), [
            'created_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[PostMapping(path: '/admin/ds/ex/currency/createPair')]
    #[Permission(code: 'ds:ex:currency:create')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function createPair(): Result
    {
        $data = $this->getRequestData();
        $this->service->createPair((int)$data['currency_id'], $data['market_type'] ?? 'spot');
        return $this->success();
    }

    #[PutMapping(path: '/admin/ds/ex/currency/save/{id}')]
    #[Permission(code: 'ds:ex:currency:save')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function save(int $id, ): Result
    {
        $this->service->updateById($id, array_merge($this->getRequestData(), [
            'updated_by' => $this->currentUser->id(),
        ]));
        return $this->success();
    }

    #[DeleteMapping(path: '/admin/ds/ex/currency/delete')]
    #[Permission(code: 'ds:ex:currency:delete')]
    #[Middleware(middleware: OperationMiddleware::class, priority: 98)]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }

    #[PostMapping(path: '/admin/ds/ex/currency/generateJson')]
    #[Permission(code: 'ds:ex:currency:create')]
    public function generateJson(): Result
    {
        $result = $this->service->generateJson();
        return $this->success($result);
    }
}
