<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class FeedCommentRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    /**
     * 通用验证规则（所有方法都会应用）
     */
    public function commonRules(): array
    {
        return [
            'target_type' => 'integer',
            'target_id' => 'integer',
            'user_id' => 'integer',
            'parent_id' => 'integer',
            'root_id' => 'integer',
            'reply_to_user_id' => 'integer|nullable',
            'content' => 'sometimes',
            'images' => 'array|nullable',
            'like_count' => 'integer',
            'reply_count' => 'integer',
            'status' => 'integer',
        ];
    }

    /**
     * 自动匹配create方法验证
     */
    public function createRules(): array
    {
        return [];
    }

    /**
     * 自动匹配save方法验证
     */
    public function saveRules(): array
    {
        return [];
    }

    /**
     * 获取验证字段的自定义名称
     */
    public function attributes(): array
    {
        return [
            'target_type' => trans('feed_comment.target_type') ?: '目标类型：1帖子 2文章',
            'target_id' => trans('feed_comment.target_id') ?: '目标ID',
            'user_id' => trans('feed_comment.user_id') ?: '评论用户ID',
            'parent_id' => trans('feed_comment.parent_id') ?: '父评论ID（0为顶级评论）',
            'root_id' => trans('feed_comment.root_id') ?: '根评论ID（用于楼中楼）',
            'reply_to_user_id' => trans('feed_comment.reply_to_user_id') ?: '回复的用户ID',
            'content' => trans('feed_comment.content') ?: '评论内容',
            'images' => trans('feed_comment.images') ?: '图片列表（JSON数组）',
            'like_count' => trans('feed_comment.like_count') ?: '点赞数',
            'reply_count' => trans('feed_comment.reply_count') ?: '回复数',
            'status' => trans('feed_comment.status') ?: '状态：1显示 0隐藏',
        ];
    }

    /**
     * 获取验证错误的自定义消息
     */
    public function messages(): array
    {
        return [
            // 可以在这里添加自定义的错误消息
        ];
    }
}
