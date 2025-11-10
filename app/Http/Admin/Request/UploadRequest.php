<?php

declare(strict_types=1);


namespace App\Http\Admin\Request;

use App\Common\Request\Traits\NoAuthorizeTrait;
use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Hyperf\Validation\Request\FormRequest;

#[Schema(
    title: '上传附件',
    properties: [
        new Property(property: 'file', description: '文件', type: 'file'),
        new Property(property: 'target', description: '使用标记,表示那张表使用', type: 'string'),
    ]
)]
class UploadRequest extends FormRequest
{
    use NoAuthorizeTrait;

    protected array $scenes = [
        'apiUpload' => [
            'file' => 'required|file',
            'target' => 'required|string',
        ],
    ];

    public function rules(): array
    {
        return [
            'file' => 'required|file',
            'target' => 'string',
        ];
    }

    public function attributes(): array
    {
        return [
            'file' => trans('attachment.file'),
            'target' => trans('attachment.target'),
        ];
    }
}
