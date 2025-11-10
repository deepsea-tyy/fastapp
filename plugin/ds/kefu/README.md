<div align="center">
  <h1>客服系统插件</h1>
</div>

<div align="center">

客服系统插件（ds/kefu）提供完整的客服功能。

</div>

## 简介

客服系统插件（ds/kefu）提供完整的客服功能，包括：
- 客服管理
- 会话管理
- 实时消息推送（WebSocket）
- 消息记录

# 安装卸载
```sh
php bin/hyperf.php plugin:install ds/kefu  --yes
```
```sh
php bin/hyperf.php plugin:uninstall ds/kefu --yes
```

## 功能模块

### 1. 客服管理
- 客服账号管理
- 客服在线状态
- 最大并发会话数设置

### 2. 会话管理
- 用户与客服的会话创建
- 会话状态管理（进行中/已结束）
- 会话列表查询

### 3. 消息管理
- 文本消息
- 图片消息
- 文件消息
- 消息已读状态

### 4. WebSocket 实时推送
- 用户发送消息自动推送给客服
- 客服发送消息自动推送给用户
- 消息格式统一

## API 接口

### 用户端 API
- `GET /api/kefu/message/list` - 获取消息列表
- `GET /api/kefu/message/getConversation` - 获取或创建会话

## WebSocket 集成

插件通过事件监听器自动推送消息到 WebSocket 客户端。需要在 WebSocket 控制器中处理 `kefu_message` 类型的消息。

## 数据库表

- `kefu` - 客服表
- `kefu_conversation` - 会话表
- `kefu_message` - 消息表
- `kefu_knowledge` - 知识库表（预留）

## 注意事项

1. WebSocket 推送依赖于 Redis 存储的 fd 映射关系
2. 用户的 fd 存储在 `ws:user:{user_id}:fd`
3. 会话分配采用负载均衡策略（按当前并发数排序）
