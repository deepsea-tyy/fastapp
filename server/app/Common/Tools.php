<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common;

use App\Common\Request\Request;
use Hyperf\AsyncQueue\JobInterface;
use Hyperf\Context\ApplicationContext;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Logger\LoggerFactory;
use Hyperf\Redis\Redis;
use Psr\Container\ContainerExceptionInterface;
use Psr\Container\ContainerInterface;
use Psr\Container\NotFoundExceptionInterface;
use Psr\EventDispatcher\EventDispatcherInterface;
use Swoole\Coroutine;
use function Hyperf\AsyncQueue\dispatch;

class Tools
{
    /**
     * 翻译函数（简化版）
     *
     * @param string $t 翻译键名
     * @param array $re 替换参数数组
     * @return array|string 翻译后的文本或数组
     */
    public static function __(string $t, array $re = [], int $userId = 0): array|string
    {
        return trans($t, $re, self::lang($userId));
    }

    public static function getContainer(): ContainerInterface
    {
        return ApplicationContext::getContainer();
    }

    /**
     * 获取当前语言代码
     *
     * @param bool $format 是否格式化（将下划线替换为横线），默认false
     * @return string 语言代码，如：zh_CN 或 zh-CN（根据format参数）
     */
    public static function lang(int $userId = 0, bool $format = false): string
    {
        if ($userId) {
            $cache = self::getUserCache($userId, ['lang']);
            return $cache['lang'] ?? 'zh-CN';
        }
        $lang = self::getHeader('accept-language');
        if ($format) $lang = str_replace('_', '-', $lang);
        return $lang ?: 'zh-CN';
    }

    /**
     * 获取HTTP请求头字段值
     *
     * @param string $field 请求头字段名
     * @return string|null 请求头字段值，不存在返回null
     */
    public static function getHeader(string $field): ?string
    {
        return self::getContainer()->get(Request::class)->getHeaderLine($field);
    }

    /**
     * 根据当前语言从多语言数据数组中获取对应文本
     *
     * @param array $data 多语言数据数组，格式：[['lang' => 'zh_CN', 'text' => '文本'], ...]
     * @param bool $format 是否格式化语言代码，默认true
     * @return string 匹配的文本，如果未找到则返回第一条文本
     */
    public static function formatLang(array $data, bool $format = true): string
    {
        $lang = Tools::lang(0, $format);
        foreach ($data as $v) {
            if ($v['lang'] == $lang) return $v['text'];
        }
        return $data[0]['text'];
    }

    /**
     * 异步写入日志到指定channel
     *
     * @param string $message 日志消息
     * @param string $level 日志级别 (debug, info, notice, warning, error, critical, alert, emergency)
     * @param string $name
     * @param string $group
     */
    public static function logAsync(string $message, string $level = 'notice', string $name = 'app', string $group = 'error'): void
    {
        Coroutine::create(static function () use ($message, $level, $name, $group) {
            try {
                if (\Hyperf\Config\config('debug')) self::getContainer()->get(StdoutLoggerInterface::class)->{$level}($message);
                $logger = self::getContainer()->get(LoggerFactory::class)->get($name, $group);

                // 验证日志级别
                $validLevels = ['debug', 'info', 'notice', 'warning', 'error', 'critical', 'alert', 'emergency'];
                if (!in_array(strtolower($level), $validLevels, true)) {
                    $level = 'notice';
                }

                $logger->{$level}($message);
            } catch (\Throwable $e) {
                // 如果指定channel失败，回退到标准输出
                self::getContainer()->get(StdoutLoggerInterface::class)->error(
                    "Log write failed for channel '{$name}|{$group}': " . $e->getMessage()
                );
            }
        });
    }

    /**
     * 异步分发事件
     *
     * @param object $event 事件对象
     */
    public static function eventDispatcher(object $event): void
    {
        Coroutine::create(static function () use ($event) {
            try {
                self::getContainer()->get(EventDispatcherInterface::class)->dispatch($event);
            } catch (\Throwable $throwable) {
                self::logAsync($throwable->getMessage(), 'error', 'event');
            }
        });
    }

    /**
     * 异步分发Redis队列任务
     *
     * @param JobInterface $job 任务对象
     * @param int|null $delay 延迟执行时间（秒），null表示立即执行
     * @param int|null $maxAttempts 最大重试次数，null使用默认值
     * @param string|null $pool Redis连接池名称，null使用默认连接池
     */
    public static function redisDispatcher(JobInterface $job, ?int $delay = null, ?int $maxAttempts = null, ?string $pool = null): void
    {
        Coroutine::create(static function () use ($job, $delay, $maxAttempts, $pool) {
            dispatch($job, $delay, $maxAttempts, $pool);
        });
    }

    /**
     * 设置用户缓存（Hash结构）
     *
     * @param int $uid 用户ID
     * @param array $param 缓存数据数组，格式：['key1' => 'value1', 'key2' => 'value2']
     * @return bool 操作结果
     */
    public static function setUserCache(int $uid, array $param): bool
    {
        /* @var redis $redis */
        $redis = self::getContainer()->get(Redis::class);
        return $redis->hMSet('u:' . $uid, $param);
    }

    /**
     * 获取用户缓存（Hash结构）
     *
     * @param int $uid 用户ID
     * @param array|string $fields 要获取的字段数组或单个字段名，格式：['key1', 'key2'] 或 'key1'
     * @return array|string 返回字段值数组或单个值，格式：['key1' => 'value1', 'key2' => 'value2'] 或 'value1'
     * @throws ContainerExceptionInterface
     * @throws NotFoundExceptionInterface
     * @throws \RedisException
     */
    public static function getUserCache(int $uid, array|string $fields): array|string
    {
        /* @var redis $redis */
        $redis = self::getContainer()->get(Redis::class);
        if (is_array($fields)) {
            return $redis->hMGet('u:' . $uid, $fields) ?: [];
        }
        return $redis->hGet('u:' . $uid, $fields) ?: '';
    }

    /**
     * 对数字进行编号化，生成唯一编号
     *
     * @param string $type 业务类型，用于区分不同业务的编号（如：order, payment, refund等）
     * @param int $length 编号长度，默认8位（不足前面补0）
     * @param string $prefix 编号前缀，默认为空（如：ORD, PAY等）
     * @param string|null $dateFormat 日期格式，用于在编号中包含日期（如：Ymd, YmdHis），null表示不包含日期
     * @return string 生成的唯一编号，格式：{prefix}{date}{序号}，如：ORD20251108000001
     */
    public static function generateNumber(string $type = 'default', int $length = 8, string $prefix = '', ?string $dateFormat = 'Ymd'): string
    {
        $redis = self::getContainer()->get(Redis::class);

        // 构建Redis键名
        $dateStr = $dateFormat ? date($dateFormat) : '';
        $key = "number:{$type}:" . ($dateStr ?: 'global');

        // 使用Redis原子操作获取自增序号
        $sequence = $redis->incr($key);

        // 如果是当天的第一个编号，设置过期时间为第二天0点（避免Redis键无限增长）
        if ($sequence === 1 && $dateStr) {
            $tomorrow = strtotime('tomorrow');
            $expireTime = $tomorrow - time();
            if ($expireTime > 0) {
                $redis->expire($key, $expireTime);
            }
        }

        // 格式化序号（补零到指定长度）
        $formattedSequence = str_pad((string)$sequence, $length, '0', STR_PAD_LEFT);

        // 组合编号：前缀 + 日期 + 序号
        return $prefix . $dateStr . $formattedSequence;
    }
}