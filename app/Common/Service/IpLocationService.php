<?php

declare(strict_types=1);

namespace App\Common\Service;

use App\Common\Tools;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Guzzle\ClientFactory;
use Psr\SimpleCache\CacheInterface;

/**
 * IP地理位置查询服务
 * 支持多个免费API服务，自动降级切换
 */
class IpLocationService
{
    protected CacheInterface $cache;
    protected ClientFactory $clientFactory;
    protected ConfigInterface $config;

    /**
     * API服务列表（按优先级排序）
     */
    protected array $apis = [
        'ipapi' => [
            'name' => 'ipapi.co',
            'url' => 'https://ipapi.co/{ip}/json/',
            'lang_support' => true,
            'free_limit' => 1000, // 每天免费额度
        ],
        'ipapi_com' => [
            'name' => 'ip-api.com',
            'url' => 'http://ip-api.com/json/{ip}',
            'lang_support' => false, // 不支持多语言，但数据详细
            'free_limit' => 45, // 每分钟免费额度
        ],
        'ipapi_io' => [
            'name' => 'ip-api.io',
            'url' => 'https://ip-api.io/json/{ip}',
            'lang_support' => false,
            'free_limit' => 100, // 每天免费额度
        ],
    ];

    public function __construct(
        CacheInterface $cache,
        ClientFactory $clientFactory,
        ConfigInterface $config
    ) {
        $this->cache = $cache;
        $this->clientFactory = $clientFactory;
        $this->config = $config;
    }

    /**
     * 根据IP查询地理位置信息
     *
     * @param string $ip IP地址
     * @param string $lang 语言代码（如：zh-CN, en, zh-TW）
     * @return array|null 返回地理位置信息，失败返回null
     */
    public function query(string $ip, string $lang = 'zh-CN'): ?array
    {
        // 验证IP地址
        if (!filter_var($ip, FILTER_VALIDATE_IP)) {
            Tools::logAsync("Invalid IP address: {$ip}", 'warning', 'ip-location');
            return null;
        }

        // 检查缓存（缓存24小时）
        $cacheKey = "ip_location:{$ip}:{$lang}";
        $cached = $this->cache->get($cacheKey);
        if ($cached !== null) {
            return $cached;
        }

        // 内网IP直接返回
        if ($this->isPrivateIp($ip)) {
            $result = $this->createEmptyResult($ip);
            $this->cache->set($cacheKey, $result, 86400);
            return $result;
        }

        // 尝试各个API服务
        foreach ($this->apis as $apiKey => $apiConfig) {
            try {
                $result = $this->queryFromApi($apiKey, $apiConfig, $ip, $lang);
                if ($result !== null) {
                    // 缓存结果24小时
                    $this->cache->set($cacheKey, $result, 86400);
                    return $result;
                }
            } catch (\Throwable $e) {
                Tools::logAsync("API {$apiConfig['name']} failed: " . $e->getMessage(), 'warning', 'ip-location');
                continue;
            }
        }

        Tools::logAsync("All IP location APIs failed for IP: {$ip}", 'error', 'ip-location');
        return null;
    }

    /**
     * 从指定API查询
     */
    protected function queryFromApi(string $apiKey, array $apiConfig, string $ip, string $lang): ?array
    {
        $url = str_replace('{ip}', $ip, $apiConfig['url']);
        
        // 添加语言参数（如果支持）
        if ($apiConfig['lang_support'] && $apiKey === 'ipapi') {
            $langCode = $this->convertLangCode($lang);
            $url .= "?lang={$langCode}";
        }

        $client = $this->clientFactory->create([
            'timeout' => 5,
            'verify' => true,
        ]);

        try {
            $response = $client->get($url);
            
            // 检查HTTP状态码
            if ($response->getStatusCode() !== 200) {
                Tools::logAsync("API {$apiConfig['name']} returned status code: {$response->getStatusCode()}", 'warning', 'ip-location');
                return null;
            }

            $body = $response->getBody()->getContents();
            if (empty($body)) {
                return null;
            }

            $data = json_decode($body, true);
            if (!is_array($data)) {
                Tools::logAsync("API {$apiConfig['name']} returned invalid JSON", 'warning', 'ip-location');
                return null;
            }

            return $this->normalizeData($apiKey, $data, $lang);
        } catch (\GuzzleHttp\Exception\RequestException $e) {
            Tools::logAsync("API {$apiConfig['name']} request failed: " . $e->getMessage(), 'warning', 'ip-location');
            return null;
        } catch (\Throwable $e) {
            Tools::logAsync("API {$apiConfig['name']} error: " . $e->getMessage(), 'warning', 'ip-location');
            return null;
        }
    }

    /**
     * 标准化不同API返回的数据格式
     */
    protected function normalizeData(string $apiKey, array $data, string $lang): ?array
    {
        $rawData = [];

        switch ($apiKey) {
            case 'ipapi':
                // ipapi.co 格式
                if (isset($data['error'])) {
                    return null;
                }
                $rawData = [
                    'ip' => $data['ip'] ?? '',
                    'country' => $data['country_name'] ?? '',
                    'country_code' => $data['country_code'] ?? '',
                    'region' => $data['region'] ?? '',
                    'city' => $data['city'] ?? '',
                    'isp' => $data['org'] ?? '',
                    'latitude' => $data['latitude'] ?? null,
                    'longitude' => $data['longitude'] ?? null,
                ];
                break;

            case 'ipapi_com':
                // ip-api.com 格式
                if (($data['status'] ?? '') !== 'success') {
                    return null;
                }
                $rawData = [
                    'ip' => $data['query'] ?? '',
                    'country' => $data['country'] ?? '',
                    'country_code' => $data['countryCode'] ?? '',
                    'region' => $data['regionName'] ?? '',
                    'city' => $data['city'] ?? '',
                    'isp' => $data['isp'] ?? '',
                    'latitude' => $data['lat'] ?? null,
                    'longitude' => $data['lon'] ?? null,
                ];
                break;

            case 'ipapi_io':
                // ip-api.io 格式
                if (isset($data['error'])) {
                    return null;
                }
                $rawData = [
                    'ip' => $data['ip'] ?? '',
                    'country' => $data['country_name'] ?? '',
                    'country_code' => $data['country_code'] ?? '',
                    'region' => $data['region_name'] ?? '',
                    'city' => $data['city'] ?? '',
                    'isp' => $data['organisation'] ?? '',
                    'latitude' => $data['latitude'] ?? null,
                    'longitude' => $data['longitude'] ?? null,
                ];
                break;

            default:
                return null;
        }

        // 验证和清理数据
        return $this->cleanAndValidateData($rawData);
    }

    /**
     * 创建空结果结构（用于内网IP或默认值）
     */
    protected function createEmptyResult(string $ip): array
    {
        return [
            'ip' => $ip,
            'country' => '',
            'country_code' => '',
            'region' => '',
            'city' => '',
            'isp' => '',
            'latitude' => null,
            'longitude' => null,
        ];
    }

    /**
     * 清理和验证数据，确保格式统一
     */
    protected function cleanAndValidateData(array $data): ?array
    {
        // 验证IP地址必须存在
        if (empty($data['ip']) || !filter_var($data['ip'], FILTER_VALIDATE_IP)) {
            return null;
        }

        // 统一数据结构
        $result = $this->createEmptyResult($data['ip']);

        // 清理字符串字段（去除首尾空格，空字符串转为空字符串）
        $stringFields = ['country', 'country_code', 'region', 'city', 'isp'];
        foreach ($stringFields as $field) {
            $value = $data[$field] ?? '';
            $result[$field] = is_string($value) ? trim($value) : '';
        }

        // 处理经纬度（确保为float类型或null）
        $result['latitude'] = $this->normalizeCoordinate($data['latitude'] ?? null);
        $result['longitude'] = $this->normalizeCoordinate($data['longitude'] ?? null);

        return $result;
    }

    /**
     * 标准化坐标值（转换为float或null）
     */
    protected function normalizeCoordinate($value): ?float
    {
        if ($value === null || $value === '') {
            return null;
        }

        // 如果是字符串，尝试转换为float
        if (is_string($value)) {
            $value = trim($value);
            if ($value === '') {
                return null;
            }
        }

        // 转换为float
        $floatValue = filter_var($value, FILTER_VALIDATE_FLOAT);
        if ($floatValue === false) {
            return null;
        }

        // 验证坐标范围
        if (abs($floatValue) > 180) {
            return null;
        }

        return (float)$floatValue;
    }

    /**
     * 转换语言代码
     */
    protected function convertLangCode(string $lang): string
    {
        $map = [
            'zh-CN' => 'zh',
            'zh_CN' => 'zh',
            'zh-TW' => 'zh',
            'zh_TW' => 'zh',
            'en' => 'en',
            'en-US' => 'en',
            'ja' => 'ja',
            'ko' => 'ko',
        ];

        return $map[$lang] ?? 'en';
    }

    /**
     * 判断是否为内网IP
     */
    protected function isPrivateIp(string $ip): bool
    {
        return !filter_var(
            $ip,
            FILTER_VALIDATE_IP,
            FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE
        );
    }
}
