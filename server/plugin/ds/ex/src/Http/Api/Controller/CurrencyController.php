<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Http\Api\Controller;

use App\Common\AbstractController;
use App\Common\Result;
use App\Common\Tools;
use Hyperf\HttpMessage\Stream\SwooleStream;
use Hyperf\HttpServer\Contract\ResponseInterface as HttpResponse;
use Hyperf\Swagger\Annotation\Get;
use App\Common\Swagger\ResultResponse;
use Hyperf\Swagger\Annotation\HyperfServer;
use Hyperf\Swagger\Annotation\QueryParameter;
use Hyperf\Swagger\Annotation\Tag;
use Plugin\Ds\Ex\Model\Currency;
use Plugin\Ds\Ex\Model\MarketTicker;
use Psr\Http\Message\ResponseInterface;


/**
 * 币种信息控制器
 *
 * @author FastApp代码生成器
 * @date 2025-12-21 11:08:03
 */
#[Tag('币种信息')]
#[HyperfServer('http')]
class CurrencyController extends AbstractController
{
    public function __construct(
        private readonly HttpResponse $response
    )
    {
    }

    #[Get(path: '/api/ds/ex/currency/exchangeRate', operationId: 'apiCurrencyExchangeRate', summary: '汇率', tags: ['币种信息'])]
    #[ResultResponse(instance: new Result())]
    public function exchangeRate(): Result
    {
        return $this->success(Tools::getRedis()->hGetAll('exchange_rate'));
    }


    #[Get(path: '/api/ds/ex/currency/detail', operationId: 'apiCurrencyDetail', summary: '币种详情', tags: ['币种信息'])]
    #[QueryParameter(name: 'symbol', description: '币种符号 BTC', required: true, example: 'BTC')]
    #[ResultResponse(instance: new Result())]
    public function detail(): Result
    {
        $md = Currency::query()->where('symbol', $this->getRequest()->input('symbol'))->first();
        if ($md) {
            $md->name = Tools::formatLang($md->name ?? []);
            $md->description = Tools::formatLang($md->description ?? []);
        }
        return $this->success($md);
    }

    #[Get(
        path: '/api/ds/ex/currency/download',
        operationId: 'DownloadCurrencyFile',
        summary: '下载币种数据',
        tags: ['币种信息'],
    )]
    #[ResultResponse(instance: new Result())]
    public function download(): ResponseInterface
    {
        $filePath = BASE_PATH . '/storage/app/ex/market_data.json';
        $fileContent = Tools::getRedis()->get('market_data');
        $mimeType = 'application/json; charset=utf-8';

        return $this->response->withHeader('Content-Type', $mimeType)
            ->withHeader('Content-Disposition', 'attachment; filename="' . basename($filePath) . '"')
            ->withHeader('Content-Length', (string)strlen($fileContent))
            ->withBody(new SwooleStream($fileContent));
    }

    #[Get(path: '/api/ds/ex/currency/ticker', operationId: 'apiCurrencyTicker', summary: '获取Tickers行情数据', tags: ['币种信息'])]
    #[QueryParameter(name: 'symbol', description: '交易对符号（如：BTCUSDT,BNBUSDT）', required: true, example: 'BTCUSDT')]
    #[ResultResponse(instance: new Result())]
    public function ticker(): Result
    {
        $data = MarketTicker::query()
            ->whereIn('symbol', explode(',', strtoupper($this->getRequest()->input('symbol'))))
            ->get()->map(function ($ticker) {
                return [
                    'symbol' => $ticker->symbol,
                    'last_price' => (float)$ticker->last_price,
                    'open_price' => (float)$ticker->open_price,
                    'high_price' => (float)$ticker->high_price,
                    'low_price' => (float)$ticker->low_price,
                    'volume' => (float)$ticker->volume,
                    'amount' => (float)$ticker->amount,
                    'change_percent' => (float)$ticker->change_percent,
                    'change_amount' => (float)$ticker->change_amount,
                    'timestamp' => (int)$ticker->timestamp,
                ];
            });

        return $this->success($data);
    }
}
