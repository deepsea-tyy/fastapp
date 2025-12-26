import 'package:flutter/material.dart';
import 'package:fastapp/domain/entity/customer_service/customer_service.dart';
import 'package:fastapp/domain/entity/customer_service/chat_message.dart';
import 'package:fastapp/constants/app_backgrounds.dart';
import 'package:fastapp/data/network/websocket/app_websocket.dart';
import 'package:fastapp/data/network/apis/customer_service/customer_service_api.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

/// 客服聊天页面
class CustomerServiceChatScreen extends StatefulWidget {
  final AppWebSocket webSocket;
  final CustomerServiceApi customerServiceApi;

  const CustomerServiceChatScreen({
    super.key,
    required this.webSocket,
    required this.customerServiceApi,
  });

  @override
  State<CustomerServiceChatScreen> createState() =>
      _CustomerServiceChatScreenState();
}

// 样式常量
class _ChatStyles {
  static const double avatarRadiusLarge = 20.0;
  static const double avatarRadiusSmall = 16.0;
  static const double messageBubbleRadius = 12.0;
  static const double messagePadding = 12.0;
  static const double spacing = 8.0;
}

// 配置常量
class _ChatConfig {
  /// 用户发送消息后多久内不显示欢迎语（分钟）
  static const int welcomeMessageThresholdMinutes = 5;
}

class _CustomerServiceChatScreenState
    extends State<CustomerServiceChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late CustomerService _customerService;
  List<String> _quickQuestions = [];
  bool _showQuickQuestions = true;
  int? _conversationId;
  StreamSubscription<WebSocketMessage>? _messageSubscription;

  // 分页相关
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final int _pageSize = 20;
  bool _isInitializing = true; // 初始化加载状态

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService.defaultService();
    _listenToWebSocket();
    _initializeChat();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // 当滚动到接近顶部时加载更多（因为使用了reverse，实际是向上滚动）
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreMessages();
      }
    });
  }

  void _listenToWebSocket() {
    _messageSubscription = widget.webSocket.messageStream
        .where((msg) =>
            msg.type == WebSocketMessageType.customerServiceMessage ||
            msg.type == WebSocketMessageType.customerServiceMessageEnd)
        .listen((msg) {
      if (msg.type == WebSocketMessageType.customerServiceMessage) {
        _handleIncomingMessage(msg.data);
      } else if (msg.type == WebSocketMessageType.customerServiceMessageEnd) {
        _handleConversationEnd(msg.data);
      }
    });
  }

  Future<void> _initializeChat() async {
    try {
      final response = await widget.customerServiceApi.getConversation();
      _conversationId = response['id'] as int?;

      // 更新客服信息
      if (response['kefu_info'] != null) {
        final kefuInfo = response['kefu_info'] as Map<String, dynamic>;
        _customerService = CustomerService(
          id: kefuInfo['id'] as int? ?? 0,
          nickname: kefuInfo['nickname'] as String? ?? '在线客服',
          avatar: kefuInfo['avatar'] as String? ?? '',
          level: CustomerServiceLevel.intermediate,
          isOnline: kefuInfo['is_online'] as bool? ?? true,
        );
      }

      // 更新快捷问题
      if (response['help'] != null) {
        _quickQuestions = List<String>.from(response['help'] as List);
      }

      // 先加载历史消息
      if (_conversationId != null) {
        await _loadHistoryMessages();
      }

      // 判断是否需要显示欢迎消息
      final shouldShowWelcome = _shouldShowWelcomeMessage();

      // 历史消息加载完成后添加欢迎消息并更新状态
      setState(() {
        _isInitializing = false;
        if (shouldShowWelcome) {
          _messages.add(
            ChatMessage.createServiceMessage(
              content: '您好！我是${_customerService.nickname}，很高兴为您服务。请问有什么可以帮助您的？',
              serviceId: _customerService.id,
              serviceName: _customerService.nickname,
              serviceAvatar: _customerService.avatar,
            ),
          );
        }
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isInitializing = false);
      MessageService.error('加载会话失败');
    }
  }

  /// 判断是否应该显示欢迎消息
  /// 规则：如果最新消息是用户在指定时间内发送的且客服未回复，则不显示欢迎语
  bool _shouldShowWelcomeMessage() {
    if (_messages.isEmpty) return true;

    final latestMessage = _messages.last;

    // 如果最新消息是客服发的，说明客服已经回复了，不显示欢迎消息
    if (latestMessage.senderType == SenderType.service) return false;

    // 如果最新消息是系统消息，显示欢迎消息
    if (latestMessage.senderType == SenderType.system) return true;

    // 如果最新消息是用户发的，判断时间
    final messageAge = DateTime.now().difference(latestMessage.timestamp);

    // 如果消息在指定时间内，不显示欢迎语（用户刚发了消息等待回复）
    if (messageAge.inMinutes < _ChatConfig.welcomeMessageThresholdMinutes) {
      return false;
    }

    // 超过指定时间了，显示欢迎语
    return true;
  }

  Future<void> _loadHistoryMessages() async {
    if (_conversationId == null) return;

    try {
      final messages = await widget.customerServiceApi.getMessages(
        conversationId: _conversationId!,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _messages.insertAll(0, messages.map(_parseMessage));
        _hasMoreData = messages.length >= _pageSize;
      });
    } catch (e) {
      MessageService.error('加载历史消息失败');
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreData || _conversationId == null) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final messages = await widget.customerServiceApi.getMessages(
        conversationId: _conversationId!,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (messages.isEmpty) {
          _hasMoreData = false;
        } else {
          _messages.insertAll(0, messages.map(_parseMessage));
          _hasMoreData = messages.length >= _pageSize;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
      MessageService.error('加载更多消息失败');
    }
  }

  ChatMessage _parseMessage(dynamic data) {
    final messageType = data['message_type'] as int? ?? 1;
    final senderType = data['sender_type'] as int? ?? 1;

    return ChatMessage(
      id: (data['id'] ?? data['message_id']).toString(),
      content: data['content'] ?? '',
      type: _intToMessageType(messageType),
      senderType: senderType == 1 ? SenderType.user : SenderType.service,
      senderId: data['sender_id'] as int?,
      timestamp: DateTime.parse(data['created_at']),
      isRead: data['is_read'] == 1,
    );
  }

  MessageType _intToMessageType(int type) {
    switch (type) {
      case 2: return MessageType.image;
      case 3: return MessageType.file;
      default: return MessageType.text;
    }
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final message = _parseMessage(data);

      setState(() => _messages.add(message));

      // 标记客服消息为已读
      if (message.senderType == SenderType.service && _conversationId != null) {
        widget.webSocket.markCustomerServiceMessageRead(
          conversationId: _conversationId!,
          messageIds: [int.parse(message.id)],
        );
      }

      _scrollToBottom();
    } catch (e, stack) {
      debugPrint('处理消息失败: $e\n$stack');
    }
  }

  void _handleConversationEnd(dynamic data) {
    setState(() => _messages.add(ChatMessage.createSystemMessage('会话已结束')));
    _conversationId = null;
  }

  // 构建通用头像组件
  Widget _buildAvatar({
    required String? avatarUrl,
    required IconData icon,
    required double radius,
    required ThemeData theme,
    bool showOnlineIndicator = false,
  }) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      backgroundImage: (avatarUrl?.isNotEmpty ?? false)
          ? NetworkImage(avatarUrl!)
          : null,
      child: (avatarUrl?.isEmpty ?? true)
          ? Icon(icon, size: radius, color: theme.colorScheme.primary)
          : null,
    );

    if (!showOnlineIndicator) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          // 快捷问题区域
          if (_showQuickQuestions) _buildQuickQuestionsSection(),
          // 聊天消息列表
          Expanded(
            child: _buildMessageList(),
          ),
          // 输入框
          _buildInputSection(theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Row(
        children: [
          // 客服头像
          _buildAvatar(
            avatarUrl: _customerService.avatar,
            icon: Icons.support_agent,
            radius: _ChatStyles.avatarRadiusLarge,
            theme: theme,
            showOnlineIndicator: _customerService.isOnline,
          ),
          const SizedBox(width: 12),
          // 客服信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _customerService.nickname,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _customerService.level.badge,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  _customerService.isOnline
                      ? '${_customerService.level.label} · 在线'
                      : '离线',
                  style: TextStyle(
                    fontSize: 12,
                    color: _customerService.isOnline
                        ? Colors.green
                        : theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // 评分信息
        if (_customerService.rating != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _customerService.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickQuestionsSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '快捷问题',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showQuickQuestions = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickQuestions.map((question) {
              return _buildQuickQuestionChip(question, theme);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionChip(String question, ThemeData theme) {
    return InkWell(
      onTap: () => _handleQuickQuestionTap(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          question,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    // 初始化加载中
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '正在加载聊天记录...',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          '暂无消息',
          style: TextStyle(
            color: Theme.of(context).hintColor,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      reverse: true, // 反向显示，从底部开始
      itemCount: _messages.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // 加载指示器显示在最后（因为reverse，实际在顶部）
        if (index == _messages.length) {
          return _buildLoadingIndicator();
        }

        // 因为reverse=true，需要反向索引
        final message = _messages[_messages.length - 1 - index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                '上滑加载更多',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.senderType == SenderType.user;
    final isSystem = message.senderType == SenderType.system;

    if (isSystem) {
      return _buildSystemMessage(message, theme);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 客服头像（左侧）
          if (!isUser) ...[
            _buildAvatar(
              avatarUrl: message.senderAvatar,
              icon: Icons.support_agent,
              radius: _ChatStyles.avatarRadiusSmall,
              theme: theme,
            ),
            SizedBox(width: _ChatStyles.spacing),
          ],
          // 消息内容
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(_ChatStyles.messagePadding),
                  decoration: BoxDecoration(
                    color: isUser ? theme.colorScheme.primary : theme.cardColor,
                    borderRadius: BorderRadius.circular(_ChatStyles.messageBubbleRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
              ],
            ),
          ),
          // 用户头像（右侧）
          if (isUser) ...[
            SizedBox(width: _ChatStyles.spacing),
            _buildAvatar(
              avatarUrl: message.senderAvatar,
              icon: Icons.person,
              radius: _ChatStyles.avatarRadiusSmall,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage message, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.hintColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    final backgrounds = AppBackgrounds.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 快捷问题按钮
            IconButton(
              icon: Icon(
                _showQuickQuestions ? Icons.keyboard_hide : Icons.help_outline,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => setState(() => _showQuickQuestions = !_showQuickQuestions),
            ),
            const SizedBox(width: 8),
            // 输入框
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  filled: true,
                  fillColor: backgrounds.input,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            // 发送按钮
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickQuestionTap(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _conversationId == null) return;

    final tempMessage = ChatMessage.createUserMessage(content: content);
    setState(() {
      _messages.add(tempMessage);
      _messageController.clear();
    });

    widget.webSocket.sendCustomerServiceMessage(
      conversationId: _conversationId!,
      content: content,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 因为使用了reverse，滚动到0位置就是最新消息
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) return '刚刚';
    if (difference.inHours < 1) return '${difference.inMinutes}分钟前';
    if (difference.inDays < 1) return DateFormat('HH:mm').format(time);
    if (difference.inDays < 7) return '${difference.inDays}天前';
    return DateFormat('MM-dd HH:mm').format(time);
  }
}
