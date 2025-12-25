import 'package:flutter/material.dart';
import 'package:fastapp/domain/entity/customer_service/customer_service.dart';
import 'package:fastapp/domain/entity/customer_service/quick_question.dart';
import 'package:fastapp/domain/entity/customer_service/chat_message.dart';
import 'package:fastapp/constants/app_backgrounds.dart';
import 'package:intl/intl.dart';

/// 客服聊天页面
class CustomerServiceChatScreen extends StatefulWidget {
  const CustomerServiceChatScreen({super.key});

  @override
  State<CustomerServiceChatScreen> createState() =>
      _CustomerServiceChatScreenState();
}

class _CustomerServiceChatScreenState
    extends State<CustomerServiceChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late CustomerService _customerService;
  late List<QuickQuestion> _quickQuestions;
  bool _showQuickQuestions = true;

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService.defaultService();
    _quickQuestions = QuickQuestion.getDefaultQuestions();
    _initializeChat();
  }

  void _initializeChat() {
    // 添加欢迎消息
    setState(() {
      _messages.add(
        ChatMessage.createServiceMessage(
          content: '您好！我是${_customerService.nickname}，很高兴为您服务。请问有什么可以帮助您的？',
          serviceId: _customerService.id,
          serviceName: _customerService.nickname,
          serviceAvatar: _customerService.avatar,
        ),
      );
    });
  }

  @override
  void dispose() {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: _customerService.avatar.isNotEmpty
                    ? NetworkImage(_customerService.avatar)
                    : null,
                child: _customerService.avatar.isEmpty
                    ? Icon(
                        Icons.support_agent,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              // 在线状态指示器
              if (_customerService.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
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
                onPressed: () {
                  setState(() {
                    _showQuickQuestions = false;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickQuestions.take(6).map((question) {
              return _buildQuickQuestionChip(question, theme);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionChip(QuickQuestion question, ThemeData theme) {
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
          question.question,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
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
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageItem(message);
      },
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
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // 客服头像
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: message.senderAvatar?.isNotEmpty == true
                  ? NetworkImage(message.senderAvatar!)
                  : null,
              child: message.senderAvatar?.isEmpty ?? true
                  ? Icon(
                      Icons.support_agent,
                      size: 16,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          // 消息内容
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
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
                      color: isUser
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            // 用户头像
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: message.senderAvatar?.isNotEmpty == true
                  ? NetworkImage(message.senderAvatar!)
                  : null,
              child: message.senderAvatar?.isEmpty ?? true
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: theme.colorScheme.primary,
                    )
                  : null,
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
              onPressed: () {
                setState(() {
                  _showQuickQuestions = !_showQuickQuestions;
                });
              },
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

  void _handleQuickQuestionTap(QuickQuestion question) {
    _messageController.text = question.question;
    _sendMessage();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      // 添加用户消息
      _messages.add(
        ChatMessage.createUserMessage(
          content: content,
        ),
      );

      // 清空输入框
      _messageController.clear();

      // 模拟客服回复
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add(
              ChatMessage.createServiceMessage(
                content: _getAutoReply(content),
                serviceId: _customerService.id,
                serviceName: _customerService.nickname,
                serviceAvatar: _customerService.avatar,
              ),
            );
          });
          _scrollToBottom();
        }
      });
    });

    _scrollToBottom();
  }

  String _getAutoReply(String userMessage) {
    // 简单的自动回复逻辑
    if (userMessage.contains('充值')) {
      return '充值方式：\n1. 点击首页"充值"按钮\n2. 选择充值币种和网络\n3. 复制充值地址或扫描二维码\n4. 从您的钱包转账到该地址\n\n一般情况下，充值会在10-30分钟内到账。';
    } else if (userMessage.contains('提现')) {
      return '提现步骤：\n1. 进入资产页面\n2. 选择要提现的币种\n3. 点击"提现"\n4. 输入提现地址和数量\n5. 完成安全验证\n\n提现一般会在1-2小时内到账，具体时间取决于区块链网络状况。';
    } else if (userMessage.contains('交易')) {
      return '交易指南：\n1. 进入交易页面\n2. 选择交易对（如BTC/USDT）\n3. 选择交易类型（限价/市价）\n4. 输入价格和数量\n5. 确认并提交订单\n\n如需更多帮助，请告诉我具体遇到的问题。';
    } else if (userMessage.contains('手续费')) {
      return '我们的手续费非常优惠：\n• 现货交易：0.1%\n• 合约交易：挂单0.02%，吃单0.05%\n• 充值：免费\n• 提现：根据不同币种收取网络费用\n\nVIP用户可享受更低手续费，详情请查看VIP等级说明。';
    } else if (userMessage.contains('密码')) {
      return '重置密码步骤：\n1. 点击登录页面的"忘记密码"\n2. 输入注册邮箱或手机号\n3. 获取验证码\n4. 设置新密码\n\n如无法接收验证码，请联系我们的人工客服协助处理。';
    } else if (userMessage.contains('实名') || userMessage.contains('认证')) {
      return '实名认证流程：\n1. 进入个人中心\n2. 点击"身份认证"\n3. 上传身份证正反面照片\n4. 进行人脸识别\n5. 等待审核（一般1-2个工作日）\n\n完成实名认证后可享受更高的交易额度和更多功能。';
    } else if (userMessage.contains('活动') || userMessage.contains('优惠')) {
      return '当前活动：\n• 新用户注册送50 USDT体验金\n• 完成首次交易返20 USDT\n• 邀请好友双方各得佣金\n\n更多活动详情请查看"活动中心"。';
    } else {
      return '感谢您的咨询。如果您需要更详细的帮助，请描述具体问题，或者选择上方的快捷问题。我会尽快为您解答。';
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM-dd HH:mm').format(time);
    }
  }
}
