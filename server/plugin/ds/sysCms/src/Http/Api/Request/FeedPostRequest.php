<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Api\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

/**
 * 信息流帖子API表单验证
 */
class FeedPostRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    /**
     * 通用验证规则
     */
    public function commonRules(): array
    {
        return [];
    }

    /**
     * create 方法验证规则
     */
    public function createRules(): array
    {
        return [
            'type' => 'sometimes|integer|in:1,2',
            'content_type' => 'sometimes|integer|in:1,2,3,4',
            'title' => 'sometimes|string|max:200',
            'content' => 'required|string|max:10000',
            'images' => 'sometimes|array',
            'images.*' => 'string',
            'videos' => 'sometimes|array',
            'videos.*' => 'string',
        ];
    }

    /**
     * update 方法验证规则
     */
    public function updateRules(): array
    {
        return [
            'id' => 'required|integer',
            'status' => 'sometimes|integer|in:0,1,2',
            'is_top' => 'sometimes|integer|in:0,1',
        ];
    }

    /**
     * delete 方法验证规则
     */
    public function deleteRules(): array
    {
        return [
            'id' => 'required|integer',
        ];
    }

    /**
     * 获取验证字段的自定义名称
     */
    public function attributes(): array
    {
        return [
            'type' => '帖子类型',
            'content_type' => '内容类型',
            'title' => '标题',
            'content' => '内容',
            'images' => '图片列表',
            'images.*' => '图片URL',
            'videos' => '视频列表',
            'videos.*' => '视频URL',
            'status' => '状态',
            'is_top' => '是否置顶',
            'id' => '帖子ID',
        ];
    }

    /**
     * 获取验证错误的自定义消息
     */
    public function messages(): array
    {
        return [
            'type.in' => '帖子类型必须是 1（帖子）或 2（文章）',
            'content_type.in' => '内容类型必须是 1（纯文本）、2（图文）、3（视频）或 4（链接）',
            'status.in' => '状态必须是 0（草稿）、1（已发布）或 2（已下架）',
            'is_top.in' => '置顶标识必须是 0（否）或 1（是）',
            'content.required' => '内容不能为空',
            'content.max' => '内容不能超过10000个字符',
            'title.max' => '标题不能超过200个字符',
            'id.required' => '帖子ID不能为空',
        ];
    }
}
