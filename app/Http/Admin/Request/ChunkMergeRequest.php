<?php

declare(strict_types=1);

namespace App\Http\Admin\Request;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Hyperf\Validation\Request\FormRequest;

#[Schema(
    title: '分片合并',
    properties: [
        new Property(property: 'file_md5', description: '文件MD5值', type: 'string'),
        new Property(property: 'total_chunks', description: '总分片数', type: 'integer'),
        new Property(property: 'filename', description: '文件名', type: 'string'),
    ]
)]
class ChunkMergeRequest extends FormRequest
{
    use NoAuthorizeTrait;

    public function rules(): array
    {
        return [
            'file_md5' => 'required|string|size:32',
            'total_chunks' => 'required|integer|min:1',
            'filename' => 'required|string|max:255',
        ];
    }

    public function attributes(): array
    {
        return [
            'file_md5' => '文件MD5值',
            'total_chunks' => '总分片数',
            'filename' => '文件名',
        ];
    }
}