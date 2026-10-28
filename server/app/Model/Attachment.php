<?php

declare(strict_types=1);


namespace App\Model;

use App\Common\Tools;
use Carbon\Carbon;
use Hyperf\Database\Model\Events\Deleted;
use Hyperf\DbConnection\Model\Model;

/**
 * @property int $id 主键
 * @property string $storage_mode 存储模式 (local=本地,oss=阿里云,qiniu=七牛云,cos=腾讯云)
 * @property string $origin_name 原文件名
 * @property string $object_name 新文件名
 * @property string $hash 文件hash
 * @property string $mime_type 资源类型
 * @property string $suffix 文件后缀
 * @property int $size_byte 字节数
 * @property string $size_info 文件大小
 * @property string $url url地址
 * @property int $created_by 创建者
 * @property int $updated_by 更新者
 * @property Carbon $created_at 创建时间
 * @property Carbon $updated_at 更新时间
 * @property string $remark 备注
 * @property array|null $image_wh 图片宽高[w,h]，null=未标准化
 * @property array|null $infer 推理快照：appearance_selection/seed/width/height/steps/cfg
 * @property int|null $duration_ms 音频/视频时长(ms)；0=非音视频或未探测
 * @property int $source 来源:0=系统AI生成,1=用户上传
 * @property int|null $parent_id 来源附件ID
 */
final class Attachment extends Model
{
    /**
     * The table associated with the model.
     */
    protected ?string $table = 'attachment';

    /**
     * The attributes that are mass assignable.
     */
    protected array $fillable = ['id', 'storage_mode', 'origin_name', 'object_name', 'hash', 'mime_type', 'suffix', 'size_byte', 'size_info', 'url', 'created_by', 'updated_by', 'created_at', 'updated_at', 'remark', 'image_wh', 'infer', 'duration_ms', 'source', 'asset_type', 'parent_id'];

    /**
     * The attributes that should be cast to native types.
     */
    protected array $casts = ['id' => 'integer', 'size_byte' => 'integer', 'created_by' => 'integer', 'updated_by' => 'integer', 'image_wh' => 'array', 'infer' => 'array', 'duration_ms' => 'integer', 'source' => 'integer', 'parent_id' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];

    protected function asJson(mixed $value): false|string
    {
        return json_encode($value, JSON_UNESCAPED_UNICODE);
    }

    public function absoluteStoragePath(): string
    {
        return Tools::storage_path(parse_url($this->url, PHP_URL_PATH));
    }

    public function deleted(Deleted $event): void
    {
        @unlink($this->absoluteStoragePath());
    }

    /**
     * 推理快照只留独有字段，不写 asset_type / image_wh / created_at。
     *
     * @param  array<string, mixed>  $infer
     * @return array<string, mixed>|null
     */
    public static function compactInfer(array $infer): ?array
    {
        $out = [];
        $selection = $infer['appearance_selection'] ?? null;
        if (is_array($selection) && $selection !== []) {
            $out['appearance_selection'] = $selection;
        }
        foreach (['seed', 'width', 'height', 'steps'] as $key) {
            if (!array_key_exists($key, $infer)) {
                continue;
            }
            $value = (int) $infer[$key];
            if ($value > 0) {
                $out[$key] = $value;
            }
        }
        if (array_key_exists('cfg', $infer)) {
            $cfg = (float) $infer['cfg'];
            if ($cfg > 0) {
                $out['cfg'] = $cfg;
            }
        }

        return $out ?: null;
    }

    /** @return array<string, mixed> */
    public function inferAppearance(): array
    {
        $selection = is_array($this->infer) ? ($this->infer['appearance_selection'] ?? null) : null;

        return is_array($selection) ? $selection : [];
    }
}
