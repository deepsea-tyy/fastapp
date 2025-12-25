/// 消息类型
enum MessageType {
  text, // 文本消息
  image, // 图片消息
  file, // 文件消息
  system; // 系统消息
}

/// 消息发送者类型
enum SenderType {
  user, // 用户
  service, // 客服
  system; // 系统
}

/// 聊天消息实体
class ChatMessage {
  /// 消息ID
  final String id;

  /// 消息内容
  final String content;

  /// 消息类型
  final MessageType type;

  /// 发送者类型
  final SenderType senderType;

  /// 发送者ID
  final int? senderId;

  /// 发送者昵称
  final String? senderName;

  /// 发送者头像
  final String? senderAvatar;

  /// 发送时间
  final DateTime timestamp;

  /// 是否已读
  final bool isRead;

  /// 附加数据（图片URL、文件URL等）
  final Map<String, dynamic>? extraData;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.senderType,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.timestamp,
    this.isRead = false,
    this.extraData,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      type: _parseMessageType(json['type']),
      senderType: _parseSenderType(json['sender_type']),
      senderId: json['sender_id'] as int?,
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      extraData: json['extra_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'sender_type': senderType.name,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'extra_data': extraData,
    };
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type is String) {
      try {
        return MessageType.values.firstWhere((e) => e.name == type);
      } catch (_) {
        return MessageType.text;
      }
    }
    return MessageType.text;
  }

  static SenderType _parseSenderType(dynamic type) {
    if (type is String) {
      try {
        return SenderType.values.firstWhere((e) => e.name == type);
      } catch (_) {
        return SenderType.user;
      }
    }
    return SenderType.user;
  }

  /// 创建用户文本消息
  static ChatMessage createUserMessage({
    required String content,
    int? userId,
    String? userName,
    String? userAvatar,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.text,
      senderType: SenderType.user,
      senderId: userId,
      senderName: userName,
      senderAvatar: userAvatar,
      timestamp: DateTime.now(),
    );
  }

  /// 创建客服文本消息
  static ChatMessage createServiceMessage({
    required String content,
    int? serviceId,
    String? serviceName,
    String? serviceAvatar,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.text,
      senderType: SenderType.service,
      senderId: serviceId,
      senderName: serviceName,
      senderAvatar: serviceAvatar,
      timestamp: DateTime.now(),
    );
  }

  /// 创建系统消息
  static ChatMessage createSystemMessage(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      senderType: SenderType.system,
      timestamp: DateTime.now(),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    SenderType? senderType,
    int? senderId,
    String? senderName,
    String? senderAvatar,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? extraData,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      extraData: extraData ?? this.extraData,
    );
  }
}
