<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Controller;

use App\Http\Admin\Controller\AbstractController;
use App\Common\Result;
use Plugin\Ds\SysCms\Http\Admin\Service\AppPageContentSyncService as Service;
use Plugin\Ds\SysCms\Command\Service\AppPageContentGeneratorService;
use Hyperf\HttpServer\Annotation\Middleware;
use App\Http\Admin\Permission;
use App\Http\Admin\Middleware\PermissionMiddleware;
use App\Common\Middleware\AccessTokenMiddleware;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\GetMapping;
use Hyperf\HttpServer\Annotation\PostMapping;
use Hyperf\HttpServer\Annotation\DeleteMapping;


/**
 * App页面内容同步版本管理控制器
 *
 * @author FastApp代码生成器
 * @date 2025-12-08
 */
#[Controller]
#[Middleware(middleware: AccessTokenMiddleware::class, priority: 100)]
#[Middleware(middleware: PermissionMiddleware::class, priority: 99)]
class AppPageContentSyncController extends AbstractController
{
    public function __construct(
        private readonly Service $service,
        private readonly AppPageContentGeneratorService $generatorService
    ) {}

    #[GetMapping(path: '/admin/ds/sysCms/app_page_content_sync/list')]
    #[Permission(code: 'ds:sysCms:app_page_content_sync:list')]
    public function pageList(): Result
    {
        return $this->success(
            $this->service->page(
                $this->getRequestData(),
                $this->getCurrentPage(),
                $this->getPageSize()
            )
        );
    }

    #[PostMapping(path: '/admin/ds/sysCms/app_page_content_sync/generate')]
    #[Permission(code: 'ds:sysCms:app_page_content_sync:generate')]
    public function generate(): Result
    {
        $result = $this->generatorService->generate();
        return $this->success($result, '文件生成成功');
    }

    #[DeleteMapping(path: '/admin/ds/sysCms/app_page_content_sync/delete')]
    #[Permission(code: 'ds:sysCms:app_page_content_sync:delete')]
    public function delete(): Result
    {
        $this->service->deleteById($this->getRequestData(), []);
        return $this->success();
    }
}

