<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu\Schema;

use Hyperf\Swagger\Annotation\Property;
use Hyperf\Swagger\Annotation\Schema;
use Plugin\Ds\Kefu\Model\KefuMessage;

/**
 * 客服消息表
 */
#[Schema(title: 'KefuMessageSchema')]
class KefuMessageSchema implements \JsonSerializable
{
    #[Property(property: 'id', title: 'ID', type: 'bigint')]
    public string $id;

    #[Property(property: 'conversation_id', title: '会话ID', type: 'bigint')]
    public string $conversation_id;

    #[Property(property: 'sender_id', title: '发送者ID', type: 'bigint')]
    public string $sender_id;

    #[Property(property: 'sender_type', title: '发送者类型：1-用户，2-客服', type: 'tinyint')]
    public string $sender_type;

    #[Property(property: 'content', title: '消息内容', type: 'text')]
    public string $content;

    #[Property(property: 'message_type', title: '消息类型：1-文本，2-图片，3-文件', type: 'tinyint')]
    public string $message_type;

    #[Property(property: 'file_url', title: '文件URL', type: 'varchar')]
    public ?string $file_url;

    #[Property(property: 'is_read', title: '是否已读：0-未读，1-已读', type: 'tinyint')]
    public string $is_read;

    #[Property(property: 'read_at', title: '阅读时间', type: 'timestamp')]
    public ?string $read_at;

    #[Property(property: 'created_at', title: 'created_at', type: 'timestamp')]
    public string $created_at;

    #[Property(property: 'updated_at', title: 'updated_at', type: 'timestamp')]
    public string $updated_at;

    public function __construct(KefuMessage $model)
    {
        $this->id = $model->id;
        $this->conversation_id = $model->conversation_id;
        $this->sender_id = $model->sender_id;
        $this->sender_type = $model->sender_type;
        $this->content = $model->content;
        $this->message_type = $model->message_type;
        $this->file_url = $model->file_url;
        $this->is_read = $model->is_read;
        $this->read_at = $model->read_at?->toDateTimeString();
        $this->created_at = $model->created_at->toDateTimeString();
        $this->updated_at = $model->updated_at->toDateTimeString();
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'conversation_id' => $this->conversation_id,
            'sender_id' => $this->sender_id,
            'sender_type' => $this->sender_type,
            'content' => $this->content,
            'message_type' => $this->message_type,
            'file_url' => $this->file_url,
            'is_read' => $this->is_read,
            'read_at' => $this->read_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at
        ];
    }
}
