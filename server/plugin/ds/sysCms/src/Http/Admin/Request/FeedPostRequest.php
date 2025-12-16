<?php

declare(strict_types=1);
namespace Plugin\Ds\SysCms\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class FeedPostRequest extends FormRequest
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
            'user_id' => 'integer',
            'content_type' => 'integer',
            'title' => 'sometimes|nullable',
            'content' => 'sometimes',
            'images' => 'array|nullable',
            'videos' => 'array|nullable',
            'link_url' => 'sometimes|nullable',
            'link_meta' => 'array|nullable',
            'quoted_type' => 'integer|nullable',
            'quoted_id' => 'integer|nullable',
            'audit_status' => 'integer',
            'audited_at' => 'date|nullable',
            'is_top' => 'integer',
            'is_hot' => 'integer',
            'status' => 'integer',
            'view_count' => 'integer',
            'like_count' => 'integer',
            'comment_count' => 'integer',
            'share_count' => 'integer',
            'collect_count' => 'integer',
            'quote_count' => 'integer',
            'ip' => 'ip|nullable',
            'device_type' => 'sometimes|nullable',
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
            'user_id' => trans('feed_post.user_id') ?: '发布用户ID',
            'content_type' => trans('feed_post.content_type') ?: '内容类型：1纯文本 2图文 3视频 4链接',
            'title' => trans('feed_post.title') ?: '标题（可选）',
            'content' => trans('feed_post.content') ?: '内容',
            'images' => trans('feed_post.images') ?: '图片列表（JSON数组）',
            'videos' => trans('feed_post.videos') ?: '视频列表（JSON数组）',
            'link_url' => trans('feed_post.link_url') ?: '外链地址',
            'link_meta' => trans('feed_post.link_meta') ?: '链接元数据（标题、描述、封面等）',
            'quoted_type' => trans('feed_post.quoted_type') ?: '引用类型：1帖子 2文章',
            'quoted_id' => trans('feed_post.quoted_id') ?: '引用的内容ID',
            'audit_status' => trans('feed_post.audit_status') ?: '审核状态：0待审核 1已通过 2已拒绝',
            'audited_at' => trans('feed_post.audited_at') ?: '审核时间',
            'is_top' => trans('feed_post.is_top') ?: '是否置顶：0否 1是',
            'is_hot' => trans('feed_post.is_hot') ?: '是否热门：0否 1是',
            'status' => trans('feed_post.status') ?: '状态：1显示 0隐藏',
            'view_count' => trans('feed_post.view_count') ?: '浏览次数',
            'like_count' => trans('feed_post.like_count') ?: '点赞数',
            'comment_count' => trans('feed_post.comment_count') ?: '评论数',
            'share_count' => trans('feed_post.share_count') ?: '分享数',
            'collect_count' => trans('feed_post.collect_count') ?: '收藏数',
            'quote_count' => trans('feed_post.quote_count') ?: '引用数',
            'ip' => trans('feed_post.ip') ?: '发布IP',
            'device_type' => trans('feed_post.device_type') ?: '设备类型：ios, android, web',
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
