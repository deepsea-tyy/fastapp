<?php
/**
 * FastApp.
 * 11/4/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Websocket;

/**
 * WebSocket消息处理器接口
 * 插件需要实现此接口来注册自己的WebSocket消息处理器
 */
interface WsMessageHandlerInterface
{
    /**
     * 获取该处理器支持的所有action映射（需要认证的接口）
     * 返回格式: ['action_name' => 'methodName']
     * 例如: ['kefu_message_send' => 'kefuMessageSend']
     *
     * @return array<string, string>
     */
    public function getActions(): array;

    /**
     * 获取该处理器支持的访客模式action映射（无需认证的接口）
     * 返回格式: ['visitor.action_name' => 'methodName']
     * 例如: ['visitor.market.hot' => 'visitorGetHotTickers']
     *
     * 注意：访客接口的 action 必须以 'visitor.' 开头
     *
     * @return array<string, string>
     */
    public function getVisitorActions(): array;
}

