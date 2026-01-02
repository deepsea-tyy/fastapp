<?php
/**
 * FastApp.
 * 1/2/26
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Middleware\TokenMiddleware;
use App\Common\Result;
use App\Common\Swagger\ResultResponse;
use App\Http\CurrentUser;
use Hyperf\HttpServer\Annotation\Middleware;
use Hyperf\Swagger\Annotation\{Get, Post, Delete, HyperfServer, QueryParameter, RequestBody, JsonContent, Tag, Property};
use Plugin\Ds\Ex\Http\Api\Service\SpotOrderService;

#[Tag(name: "现货交易")]
#[HyperfServer(name: 'http')]
class SpotController extends AbstractController
{
    public function __construct(
        protected readonly CurrentUser $currentUser,
        protected readonly SpotOrderService $orderService
    ) {
    }

    /**
     * 下单
     *
     * @return Result
     */
    #[Post(path: '/api/spot/order/place', operationId: 'SpotOrderPlace', summary: '现货下单', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['现货交易'])]
    #[RequestBody(
        content: new JsonContent(
            required: ['symbol', 'side', 'type', 'quantity'],
            properties: [
                new Property(property: 'symbol', description: '交易对符号', type: 'string', example: 'BTCUSDT'),
                new Property(property: 'side', description: '订单方向 buy/sell', type: 'string', example: 'buy'),
                new Property(property: 'type', description: '订单类型 limit/market', type: 'string', example: 'limit'),
                new Property(property: 'quantity', description: '数量', type: 'number', example: 0.001),
                new Property(property: 'price', description: '价格（限价单必填）', type: 'number', example: 50000),
                new Property(property: 'amount', description: '金额（市价买入必填）', type: 'number', example: 100),
                new Property(property: 'client_order_id', description: '客户端订单ID', type: 'string', example: ''),
            ]
        )
    )]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function placeOrder(): Result
    {
        $params = $this->getRequestData();

        try {
            $userId = $this->currentUser->id();
            $order = $this->orderService->placeOrder($userId, $params);

            // 格式化返回数据
            $pair = $order->marketPair;
            $data = [
                'id' => $order->order_id,
                'symbol' => $pair ? $pair->symbol : '',
                'type' => strtolower($order->type),
                'side' => strtolower($order->side),
                'status' => 'pending',
                'price' => $order->price > 0 ? (float)$order->price : null,
                'quantity' => (float)$order->quantity,
                'filledQuantity' => 0.0,
                'filledAmount' => 0.0,
                'avgPrice' => null,
                'createdAt' => $order->created_at->getTimestamp() * 1000,
                'updatedAt' => $order->updated_at->getTimestamp() * 1000,
            ];

            return $this->success($data, '下单成功');
        } catch (\Throwable $e) {
            return $this->error($e->getMessage());
        }
    }

    /**
     * 获取订单列表
     *
     * @return Result
     */
    #[Get(path: '/api/spot/order/list', operationId: 'SpotOrderList', summary: '获取现货订单列表', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['现货交易'])]
    #[QueryParameter(name: 'symbol', description: '交易对符号', required: false, example: 'BTCUSDT')]
    #[QueryParameter(name: 'status', description: '订单状态', required: false, example: 'pending')]
    #[QueryParameter(name: 'side', description: '订单方向', required: false, example: 'buy')]
    #[QueryParameter(name: 'start_time', description: '开始时间戳（秒）', required: false)]
    #[QueryParameter(name: 'end_time', description: '结束时间戳（秒）', required: false)]
    #[QueryParameter(name: 'page', description: '页码', required: false, example: '1')]
    #[QueryParameter(name: 'limit', description: '每页数量', required: false, example: '50')]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function getOrderList(): Result
    {
        $params = $this->getRequestData();

        try {
            $userId = $this->currentUser->id();
            $result = $this->orderService->getOrderList($userId, $params);
            return $this->success($result);
        } catch (\Throwable $e) {
            return $this->error($e->getMessage());
        }
    }

    /**
     * 取消订单
     *
     * @return Result
     */
    #[Delete(path: '/api/spot/order/cancel', operationId: 'SpotOrderCancel', summary: '取消现货订单', security: [['Bearer' => [], 'ApiKey' => []]], tags: ['现货交易'])]
    #[QueryParameter(name: 'order_id', description: '订单ID', required: true, example: '1234567890123')]
    #[ResultResponse(instance: new Result())]
    #[Middleware(middleware: TokenMiddleware::class)]
    public function cancelOrder(): Result
    {
        $params = $this->getRequestData();
        $orderId = $params['order_id'] ?? '';

        if (empty($orderId)) {
            return $this->error('订单ID不能为空');
        }

        try {
            $userId = $this->currentUser->id();
            $this->orderService->cancelOrder($userId, $orderId);
            return $this->success(null, '取消订单成功');
        } catch (\Throwable $e) {
            return $this->error($e->getMessage());
        }
    }
}