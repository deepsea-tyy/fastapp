<?php

declare(strict_types=1);


namespace App\Http\Common\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Validation\Request\FormRequest;

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
