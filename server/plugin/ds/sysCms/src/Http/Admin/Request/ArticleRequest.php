<?php

declare(strict_types=1);

namespace Plugin\Ds\SysCms\Http\Admin\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class ArticleRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    // 默认验证
    public function commonRules(): array
    {
        return [
            'title' => ['array'],
            'subtitle' => ['array'],
            'author' => ['sometimes'],
            'cover' => ['array'],
            'video' => ['array'],
            'release_at' => ['date', 'nullable'],
            'brief' => ['array'],
            'content' => ['array'],
            'remark' => ['sometimes'],
            'sort' => ['integer'],
            'view_count' => ['integer'],
            'like_count' => ['integer'],
            'comment_count' => ['integer'],
            'share_count' => ['integer'],
            'collect_count' => ['integer'],
            'status' => ['integer'],
            'code' => ['sometimes'],
            'category_id' => ['array'],
        ];
    }

    // 自动匹配create方法验证
    public function createRules(): array
    {
        return [];
    }

    // 自动匹配save方法验证
    public function saveRules(): array
    {
        return [];
    }

    public function attributes(): array
    {
        return [
            'title' => trans('article.title') ?: '标题',
            'subtitle' => trans('article.subtitle') ?: '副标题',
            'author' => trans('article.author') ?: '作者',
            'cover' => trans('article.cover') ?: '封面',
            'video' => trans('article.video') ?: '视频',
            'release_at' => trans('article.release_at') ?: '发布日期',
            'brief' => trans('article.brief') ?: '摘要',
            'content' => trans('article.content') ?: '内容',
            'remark' => trans('article.remark') ?: '备注',
            'sort' => trans('article.sort') ?: '排序',
            'view_count' => trans('article.view_count') ?: '浏览数',
            'like_count' => trans('article.like_count') ?: '点赞数',
            'comment_count' => trans('article.comment_count') ?: '评论数',
            'share_count' => trans('article.share_count') ?: '分享数',
            'collect_count' => trans('article.collect_count') ?: '收藏数',
            'status' => trans('article.status') ?: '1显示',
            'code' => trans('article.code') ?: '调用代码',
            'category_id' => trans('article.category_id') ?: '分类ID',
        ];
    }

    /**
     * 获取验证错误的自定义消息.
     */
    public function messages(): array
    {
        return [
            // 可以在这里添加自定义的错误消息
        ];
    }
}