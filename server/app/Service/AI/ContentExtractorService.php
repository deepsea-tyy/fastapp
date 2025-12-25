<?php

declare(strict_types=1);

namespace App\Service\AI;

use GuzzleHttp\Client;
use Plugin\Ds\SysConfig\Helper\CacheConfigHelper;
use Psr\Log\LoggerInterface;

/**
 * AI 内容提取服务
 * 支持 OpenAI、Claude、国内大模型
 */
class ContentExtractorService
{
    private const DEFAULT_EXTRACTION = [
        'title' => '',
        'content' => '',
        'tags' => [],
        'keyword' => [],
    ];

    private const MAX_CONTENT_LENGTH = 1500;

    private Client $httpClient;

    public function __construct()
    {
        $this->httpClient = new Client([
            'timeout' => 30,
            'verify' => false,
        ]);
    }

    /**
     * 提取内容信息
     */
    public function extractContent(string $type, array $content): array
    {
        $config = [
            'provider' => CacheConfigHelper::getConfigByKey('ai_provider', 'openai'),
            'endpoint' => CacheConfigHelper::getConfigByKey('ai_api_endpoint', 'https://api.openai.com/v1/chat/completions'),
            'api_key' => CacheConfigHelper::getConfigByKey('ai_api_key', env('OPENAI_API_KEY', '')),
            'model' => CacheConfigHelper::getConfigByKey('ai_model', 'gpt-3.5-turbo'),
        ];

        if (empty($config['api_key'])) {
            return self::DEFAULT_EXTRACTION;
        }

        $prompt = $this->buildPrompt($type, $content);
        $response = $this->callAI($prompt, $config);

        return $this->parseResponse($response);
    }

    /**
     * 构建提示词
     */
    private function buildPrompt(string $type, array $content): string
    {
        $text = $this->extractText($type, $content);
        $text = $this->limitLength($text);

        return <<<PROMPT
从以下内容中提取信息，返回JSON格式：

{$text}

返回格式：
{
    "title": "标题（最多30字）",
    "content": "摘要（最多150字）",
    "tags": ["标签1", "标签2"],
    "keyword": ["关键词1", "关键词2", "关键词3"]
}

要求：
- title: 有标题用原标题，无标题从内容生成
- content: 提取核心内容
- tags: 2-4个分类标签
- keyword: 3-8个搜索关键词
PROMPT;
    }

    /**
     * 提取文本内容
     */
    private function extractText(string $type, array $data): string
    {
        if ($type === 'article') {
            $title = $this->getText($data['title'] ?? '');
            $brief = $this->getText($data['brief'] ?? '');
            $content = $this->getText($data['content'] ?? '');
            $text = $brief ?: $content;
            return "标题：{$title}\n内容：{$text}";
        }

        if ($type === 'feed_post') {
            $title = $data['title'] ?? '';
            $content = $data['content'] ?? '';
            return "标题：{$title}\n内容：{$content}";
        }

        return json_encode($data, JSON_UNESCAPED_UNICODE);
    }

    /**
     * 调用 AI 接口
     */
    private function callAI(string $prompt, array $config): string
    {
        try {
            $provider = $config['provider'] ?? 'openai';
            $payload = $this->buildPayload($provider, $prompt, $config);

            $response = $this->httpClient->post($config['endpoint'], [
                'json' => $payload,
                'headers' => [
                    'Authorization' => 'Bearer ' . $config['api_key'],
                    'Content-Type' => 'application/json',
                ],
            ]);

            $result = json_decode($response->getBody()->getContents(), true);
            return $this->extractResponse($provider, $result);

        } catch (\Exception $e) {
            return json_encode(self::DEFAULT_EXTRACTION, JSON_UNESCAPED_UNICODE);
        }
    }

    /**
     * 构建不同提供商的请求体
     */
    private function buildPayload(string $provider, string $prompt, array $config): array
    {
        if ($provider === 'claude') {
            return [
                'model' => $config['model'],
                'max_tokens' => 1024,
                'messages' => [
                    ['role' => 'user', 'content' => $prompt],
                ],
            ];
        }

        // OpenAI 及兼容格式（国内大模型）
        return [
            'model' => $config['model'],
            'messages' => [
                ['role' => 'user', 'content' => $prompt],
            ],
            'temperature' => 0.3,
            'response_format' => ['type' => 'json_object'],
        ];
    }

    /**
     * 从不同提供商响应中提取内容
     */
    private function extractResponse(string $provider, array $result): string
    {
        if ($provider === 'claude') {
            return $result['content'][0]['text'] ?? '{}';
        }

        // OpenAI 及兼容格式
        return $result['choices'][0]['message']['content'] ?? '{}';
    }

    /**
     * 解析 AI 响应
     */
    private function parseResponse(string $response): array
    {
        try {
            $data = json_decode($response, true);

            if (!is_array($data)) {
                return self::DEFAULT_EXTRACTION;
            }

            return [
                'title' => $data['title'] ?? '',
                'content' => $data['content'] ?? '',
                'tags' => is_array($data['tags'] ?? null) ? $data['tags'] : [],
                'keyword' => is_array($data['keyword'] ?? null) ? $data['keyword'] : [],
            ];
        } catch (\Exception $e) {
            return self::DEFAULT_EXTRACTION;
        }
    }

    /**
     * 提取多语言或普通文本
     */
    private function getText($value): string
    {
        if (is_string($value)) {
            return $value;
        }

        if (is_array($value)) {
            return $value['zh-CN'] ?? $value['zh'] ?? $value['zh_CN'] ?? reset($value) ?: '';
        }

        return '';
    }

    /**
     * 限制内容长度
     */
    private function limitLength(string $content): string
    {
        $clean = strip_tags($content);

        if (mb_strlen($clean) <= self::MAX_CONTENT_LENGTH) {
            return $clean;
        }

        return mb_substr($clean, 0, self::MAX_CONTENT_LENGTH) . '...';
    }
}
