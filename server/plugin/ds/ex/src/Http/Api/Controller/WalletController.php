<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\{Get, Post, HyperfServer, QueryParameter, JsonContent, RequestBody, Tag};
use Plugin\Ds\Ex\Http\Api\Request\ExWalletRequest as Request;
use Plugin\Ds\Ex\Http\Api\Service\ExWalletService as Service;

/**
 * 钱包API控制器
 */
#[Tag('钱包账户')]
#[HyperfServer(name: 'http')]
#[Middleware(middleware: TokenMiddleware::class)]
class WalletController extends AbstractController
{
    public function __construct(
        protected readonly Service     $service,
        protected readonly CurrentUser $currentUser
    )
    {
    }

    #[Get(path: '/api/ex/wallet/balance', operationId: 'ExWalletBalance', summary: '查询账户余额', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['钱包账户'])]
    #[ResultResponse(instance: new Result())]
    public function balance(): Result
    {
        $data = $this->service->getBalance($this->currentUser->id());
        return $this->success($data);
    }

    #[Post(path: '/api/ex/wallet/transfer', operationId: 'ExWalletTransfer', summary: '账户划转', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['钱包账户'])]
    #[RequestBody(
        content: new JsonContent(
            required: ['fromWalletType', 'toWalletType', 'symbol', 'amount'],
            properties: [
                new \Hyperf\Swagger\Annotation\Property(property: 'fromWalletType', description: '源钱包类型', type: 'string', example: 'FUNDING'),
                new \Hyperf\Swagger\Annotation\Property(property: 'toWalletType', description: '目标钱包类型', type: 'string', example: 'SPOT'),
                new \Hyperf\Swagger\Annotation\Property(property: 'symbol', description: '币种', type: 'string', example: 'USDT'),
                new \Hyperf\Swagger\Annotation\Property(property: 'amount', description: '划转金额', type: 'string', example: '100.00'),
            ]
        )
    )]
    #[ResultResponse(instance: new Result())]
    public function transfer(Request $request): Result
    {
        $request->validated();
        $data = $this->getRequestData();

        try {
            $result = $this->service->transfer($this->currentUser->id(), $data['fromWalletType'], $data['toWalletType'], $data['symbol'], $data['amount']);
            return $this->success($result);
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    #[Get(path: '/api/ex/wallet/balance-log', operationId: 'ExWalletBalanceLog', summary: '查询资金流水', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['钱包账户'])]
    #[QueryParameter(name: 'symbol', description: '币种', required: false)]
    #[QueryParameter(name: 'wallet_type', description: '钱包类型', required: false)]
    #[QueryParameter(name: 'change_type', description: '变动类型', required: false)]
    #[QueryParameter(name: 'startTime', description: '开始时间', required: false)]
    #[QueryParameter(name: 'endTime', description: '结束时间', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'limit', description: '每页数量', required: false, example: '50')]
    #[ResultResponse(instance: new Result())]
    public function balanceLog(): Result
    {
        $params = $this->getRequestData();
        $data = $this->service->getBalanceLog($this->currentUser->id(), $params);
        return $this->success($data);
    }

    #[Get(path: '/api/ex/wallet/deposit-address', operationId: 'ExWalletDepositAddress', summary: '获取充值地址', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['钱包账户'])]
    #[QueryParameter(name: 'symbol', description: '币种', required: true, example: 'USDT')]
    #[QueryParameter(name: 'network', description: '网络类型', required: true, example: 'TRC20')]
    #[ResultResponse(instance: new Result())]
    public function depositAddress(): Result
    {
        $params = $this->getRequestData();

        if (empty($params['symbol']) || empty($params['network'])) {
            return $this->error('币种和网络类型不能为空');
        }

        try {
            $data = $this->service->getDepositAddress(
                $this->currentUser->id(),
                $params['symbol'],
                $params['network']
            );
            return $this->success($data);
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    #[Post(path: '/api/ex/wallet/withdraw', operationId: 'ExWalletWithdraw', summary: '申请提现', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['钱包账户'])]
    #[RequestBody(
        content: new JsonContent(
            required: ['symbol', 'network', 'address', 'amount'],
            properties: [
                new \Hyperf\Swagger\Annotation\Property(property: 'symbol', description: '币种', type: 'string', example: 'USDT'),
                new \Hyperf\Swagger\Annotation\Property(property: 'network', description: '网络类型', type: 'string', example: 'TRC20'),
                new \Hyperf\Swagger\Annotation\Property(property: 'address', description: '提现地址', type: 'string', example: 'TXyz123...'),
                new \Hyperf\Swagger\Annotation\Property(property: 'tag', description: '标签/Memo', type: 'string', example: ''),
                new \Hyperf\Swagger\Annotation\Property(property: 'amount', description: '提现金额', type: 'string', example: '100.00'),
            ]
        )
    )]
    #[ResultResponse(instance: new Result())]
    public function withdraw(Request $request): Result
    {
        $request->validated();
        $data = $this->getRequestData();

        try {
            $result = $this->service->withdraw($this->currentUser->id(), $data);
            return $this->success($result);
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }

    #[Post(path: '/api/ex/wallet/transfer-to-user', operationId: 'ExWalletTransferToUser', summary: '转账给用户', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['钱包账户'])]
    #[RequestBody(
        content: new JsonContent(
            required: ['recipient_type', 'recipient', 'symbol', 'amount'],
            properties: [
                new \Hyperf\Swagger\Annotation\Property(property: 'recipient_type', description: '收款方式：0=邮箱，1=手机号，2=用户ID', type: 'integer', example: 0),
                new \Hyperf\Swagger\Annotation\Property(property: 'recipient', description: '收款人', type: 'string', example: 'user@example.com'),
                new \Hyperf\Swagger\Annotation\Property(property: 'symbol', description: '币种', type: 'string', example: 'USDT'),
                new \Hyperf\Swagger\Annotation\Property(property: 'amount', description: '转账金额', type: 'string', example: '100.00'),
                new \Hyperf\Swagger\Annotation\Property(property: 'remark', description: '备注', type: 'string', example: '转账备注'),
            ]
        )
    )]
    #[ResultResponse(instance: new Result())]
    public function transferToUser(Request $request): Result
    {
        $request->validated();
        $data = $this->getRequestData();

        try {
            $result = $this->service->transferToUser(
                $this->currentUser->id(),
                (int)$data['recipient_type'],
                $data['recipient'],
                $data['symbol'],
                $data['amount'],
                $data['remark'] ?? ''
            );
            return $this->success($result);
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }

}

