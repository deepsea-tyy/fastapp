<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Schema;

use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Plugin\Ds\Kefu\Model\KefuConversation;

/**
 * 客服会话表
 */
#[Schema(title: 'KefuConversationSchema')]
class KefuConversationSchema implements \JsonSerializable
{
    #[Property(property: 'id', title: 'ID', type: 'bigint')]
    public string $id;

    #[Property(property: 'kefu_id', title: '关联客服', type: 'bigint')]
    public string $kefu_id;

    #[Property(property: 'user_id', title: '用户id', type: 'bigint')]
    public string $user_id;

    #[Property(property: 'status', title: '会话状态：1-进行中，2-已结束', type: 'tinyint')]
    public string $status;

    #[Property(property: 'last_message_at', title: '最后消息时间', type: 'timestamp')]
    public string $last_message_at;

    #[Property(property: 'unread_count', title: '未读消息数（用户侧）', type: 'int')]
    public string $unread_count;

    #[Property(property: 'kefu_unread_count', title: '未读消息数（客服侧）', type: 'int')]
    public string $kefu_unread_count;

    #[Property(property: 'created_at', title: 'created_at', type: 'timestamp')]
    public string $created_at;

    #[Property(property: 'updated_at', title: 'updated_at', type: 'timestamp')]
    public string $updated_at;

    public function __construct(KefuConversation $model)
    {
        $this->id = $model->id;
        $this->kefu_id = $model->kefu_id;
        $this->user_id = $model->user_id;
        $this->status = $model->status;
        $this->last_message_at = $model->last_message_at;
        $this->unread_count = $model->unread_count;
        $this->kefu_unread_count = $model->kefu_unread_count;
        $this->created_at = $model->created_at;
        $this->updated_at = $model->updated_at;
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'kefu_id' => $this->kefu_id,
            'user_id' => $this->user_id,
            'status' => $this->status,
            'last_message_at' => $this->last_message_at,
            'unread_count' => $this->unread_count,
            'kefu_unread_count' => $this->kefu_unread_count,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at
        ];
    }
}
