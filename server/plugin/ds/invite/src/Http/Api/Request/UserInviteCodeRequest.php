<?php

declare(strict_types=1);

namespace Plugin\Ds\Invite\Http\Api\Request;

use App\Common\Request\Traits\ActionRulesTrait;
use Hyperf\Validation\Request\FormRequest;

class UserInviteCodeRequest extends FormRequest
{
    use ActionRulesTrait;

    public function authorize(): bool
    {
        return true;
    }

    public function commonRules(): array
    {
        return [
            'type' => 'integer|in:1',
            'invite_code' => 'nullable|string|max:16|unique:user_invite_code,invite_code',
            'config' => 'nullable|array',
        ];
    }

    public function createRules(): array
    {
        return [
            'type' => 'required|integer|in:1',
            'invite_code' => 'nullable|string|max:16|unique:user_invite_code,invite_code',
            'config' => 'nullable|array',
        ];
    }

    public function updateRules(): array
    {
        return [
            'config' => 'nullable|array',
        ];
    }
}

