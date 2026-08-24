<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common;

use App\Common\Request\Request;
use Hyperf\Context\ApplicationContext;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Logger\LoggerFactory;
use Lcobucci\JWT\Signer\Key\InMemory;
use Psr\Container\ContainerInterface;
use Psr\SimpleCache\CacheInterface;
use Psr\EventDispatcher\EventDispatcherInterface;
use Swoole\Coroutine;

class Tools
{
    /**
     * Logger 实例缓存
     * @var array<string, \Psr\Log\LoggerInterface>
     */
    private static array $loggerInstances = [];

    public static function getContainer(): ContainerInterface
    {
        return ApplicationContext::getContainer();
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
     * 翻译函数（简化版）
     *
     * @param string $t
     * @param array $re 替换参数数组
     * @param int $userId
     * @return array|string 翻译后的文本或数组
     */
    public static function __(string $t, array $re = [], int $userId = 0): array|string
    {
        return trans($t, $re, self::lang($userId));
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
            return $cache['lang'] ?: 'zh_CN';
        }
        $lang = self::getHeader('accept-language');
        if ($format) $lang = str_replace('_', '-', $lang);
        return $lang ?: 'zh_CN';
    }

    /**
     * 根据当前语言从多语言数据数组中获取对应文本
     *
     * @param array $data 多语言数据数组，格式：[['lang' => 'zh_CN', 'text' => '文本'], ...]
     * @param int|string $userId 用户 id 或语言
     * @return string 匹配的文本，如果未找到则返回第一条文本
     */
    public static function formatLang(array $data, int|string $userId = 0): string
    {
        $lang = is_int($userId) ? Tools::lang($userId) : $userId;
        foreach ($data as $v) {
            if ($v['lang'] == $lang) return $v['text'];
        }
        return $data[0]['text'] ?? '';
    }

    public static function console(string|array $msg, string $level = 'notice'): void
    {
        if (is_array($msg)) {
            $msg = json_encode($msg, JSON_UNESCAPED_UNICODE);
        }
        self::getContainer()->get(StdoutLoggerInterface::class)->{$level}(date('Y-m-d H:i:s') . ' ' . $msg);
    }

    /**
     * 异步写入日志到指定channel（使用单例模式缓存Logger实例）
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
                if (\Hyperf\Config\config('debug')) self::console($message, $level);

                // 使用单例模式获取或创建 Logger 实例
                $cacheKey = "{$name}:{$group}";
                if (!isset(self::$loggerInstances[$cacheKey])) {
                    self::$loggerInstances[$cacheKey] = self::getContainer()->get(LoggerFactory::class)->get($name, $group);
                }
                $logger = self::$loggerInstances[$cacheKey];

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

    public static function getCache(): CacheInterface
    {
        return self::getContainer()->get(CacheInterface::class);
    }

    /**
     * 设置用户缓存
     *
     * @param int $uid 用户ID
     * @param array $param 缓存数据数组，格式：['key1' => 'value1', 'key2' => 'value2']
     * @return bool 操作结果
     */
    public static function setUserCache(int $uid, array $param): bool
    {
        $key = 'u:' . $uid;
        $existing = self::getCache()->get($key) ?: [];
        return self::getCache()->set($key, array_merge($existing, $param));
    }

    /**
     * 获取用户缓存
     *
     * @param int $uid 用户ID
     * @param array|string $fields 要获取的字段数组或单个字段名，格式：['key1', 'key2'] 或 'key1'
     * @return array|string 返回字段值数组或单个值，格式：['key1' => 'value1', 'key2' => 'value2'] 或 'value1'
     */
    public static function getUserCache(int $uid, array|string $fields): array|string
    {
        $data = self::getCache()->get('u:' . $uid) ?: [];
        if (is_array($fields)) {
            $result = [];
            foreach ($fields as $field) {
                $result[$field] = $data[$field] ?? false;
            }
            return $result ?: [];
        }
        return $data[$fields] ?? '';
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
        $cache = self::getCache();

        $dateStr = $dateFormat ? date($dateFormat) : '';
        $key = "number:{$type}:" . ($dateStr ?: 'global');

        $sequence = (int)($cache->get($key) ?: 0);
        $sequence++;
        $cache->set($key, $sequence);

        if ($sequence === 1 && $dateStr) {
            $tomorrow = strtotime('tomorrow');
            $expireTime = $tomorrow - time();
            if ($expireTime > 0) {
                $cache->set($key, $sequence, $expireTime);
            }
        }

        $formattedSequence = str_pad((string)$sequence, $length, '0', STR_PAD_LEFT);

        return $prefix . $dateStr . $formattedSequence;
    }

    public static function runtime_path(string $path = ''): string
    {
        return self::disk_root() . '/runtime/' . ltrim($path, '/');
    }

    public static function storage_path(string $path = ''): string
    {
        return self::disk_root() . '/storage/' . ltrim($path, '/');
    }

    public static function plugin_path(string $path = ''): string
    {
        if (\Phar::running(false)) {
            return 'phar://' . \Phar::running(false) . '/plugin/' . ltrim($path, '/');
        }

        return BASE_PATH . '/plugin/' . ltrim($path, '/');
    }

    /** AppData 根（SFX 同级）；storage/runtime/.env 等可写路径 */
    public static function disk_root(): string
    {
        if ($phar = \Phar::running(false)) {
            return dirname($phar);
        }

        return BASE_PATH;
    }

    /** 桌面 SFX 运行时（fastapp phar） */
    public static function is_desktop_runtime(): bool
    {
        return (bool) \Phar::running(false);
    }

    /** bundled admin UI：{disk_root}/ui/index.html */
    public static function ui_index_path(): ?string
    {
        $path = self::disk_root() . '/ui/index.html';

        return is_file($path) ? $path : null;
    }

    /** admin UI 字体：{disk_root}/ui/font/alibaba-pu-hui-ti-3/ */
    public static function app_font_path(string $locale = 'sc'): ?string
    {
        $locale = in_array($locale, ['sc', 'tc', 'jp', 'kr'], true) ? $locale : 'sc';
        $file = "{$locale}-regular.otf";
        $ui = self::ui_index_path();
        if (! $ui) {
            return null;
        }
        $path = dirname($ui) . '/font/alibaba-pu-hui-ti-3/' . $file;

        return is_file($path) ? $path : null;
    }

    public static function app_font_locale_for_user(int $userId): string
    {
        $lang = strtolower(str_replace('-', '_', self::lang($userId)));

        return match (true) {
            str_starts_with($lang, 'zh_tw'), str_starts_with($lang, 'zh_hk'), $lang === 'zh_hant' => 'tc',
            str_starts_with($lang, 'ja') => 'jp',
            str_starts_with($lang, 'ko') => 'kr',
            default => 'sc',
        };
    }

    public static function phar_path(string $path = ''): string
    {
        return self::disk_root() . '/' . ltrim($path, '/');
    }

    public static function getJwtKey(?string $secret): InMemory
    {
        if (empty($secret)) {
            throw new \RuntimeException('JWT_SECRET or JWT_API_SECRET environment variable is required');
        }

        // Try to decode as base64, if successful and round-trip matches, use base64Encoded
        $decoded = @base64_decode($secret, true);
        if ($decoded !== false && $decoded !== '' && base64_encode($decoded) === $secret) {
            // Valid base64 string
            return InMemory::base64Encoded($secret);
        }

        // Plain text, use as is
        return InMemory::plainText($secret);
    }
}