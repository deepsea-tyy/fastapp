<?php

declare(strict_types=1);


namespace App\Http\Common\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Hyperf\Validation\Request\FormRequest;

#[Schema(
    title: '上传附件',
    properties: [
        new Property(property: 'file', description: '文件', type: 'file'),
    ]
)]
#[Schema(
    title: '分片上传附件',
    properties: [
        new Property(property: 'file', description: '分片文件', type: 'file'),
        new Property(property: 'file_md5', description: '文件MD5值', type: 'string'),
        new Property(property: 'chunk_index', description: '分片索引', type: 'integer'),
        new Property(property: 'total_chunks', description: '总分片数', type: 'integer'),
        new Property(property: 'filename', description: '文件名', type: 'string'),
    ]
)]
#[Schema(
    title: '分片合并',
    properties: [
        new Property(property: 'file_md5', description: '文件MD5值', type: 'string'),
        new Property(property: 'total_chunks', description: '总分片数', type: 'integer'),
        new Property(property: 'filename', description: '文件名', type: 'string'),
    ]
)]
class UploadRequest extends FormRequest
{
    use ActionRulesTrait;
    use NoAuthorizeTrait;

    /**
     * 通用验证规则（所有方法都会应用）
     */
    public function commonRules(): array
    {
        return [];
    }

    /**
     * upload 方法验证规则
     */
    public function uploadRules(): array
    {
        return [
            'file' => 'required|file',
        ];
    }

    /**
     * uploadChunk 方法验证规则
     */
    public function uploadChunkRules(): array
    {
        return [
            'file' => 'required|file',
            'file_md5' => 'required|string|size:32',
            'chunk_index' => 'required|integer|min:0',
            'total_chunks' => 'required|integer|min:1',
            'filename' => 'required|string|max:255',
        ];
    }

    /**
     * mergeChunk 方法验证规则
     */
    public function mergeChunkRules(): array
    {
        return [
            'file_md5' => 'required|string|size:32',
            'total_chunks' => 'required|integer|min:1',
            'filename' => 'required|string|max:255',
        ];
    }

    /**
     * 通用属性（所有方法都会应用）
     */
    public function commonAttributes(): array
    {
        return [
            'file' => trans('attachment.file'),
        ];
    }

    /**
     * uploadChunk 方法属性
     */
    public function uploadChunkAttributes(): array
    {
        return [
            'file_md5' => '文件MD5值',
            'chunk_index' => '分片索引',
            'total_chunks' => '总分片数',
            'filename' => '文件名',
        ];
    }

    /**
     * mergeChunk 方法属性
     */
    public function mergeChunkAttributes(): array
    {
        return [
            'file_md5' => '文件MD5值',
            'total_chunks' => '总分片数',
            'filename' => '文件名',
        ];
    }
}
