import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/user/message/message_setting.dart';

/// 消息页面
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '消息',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: 清除消息
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MessageSettingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildMessageItem(
            context,
            icon: Icons.campaign,
            title: '公告',
            description: 'LAB 交易竞赛: 交易LAB (LAB), ...',
            date: '11/28',
          ),
          _buildMessageItem(
            context,
            icon: Icons.card_giftcard,
            title: '活动',
            description: '交易合约赢奖励',
            date: '11/27',
          ),
          _buildMessageItem(
            context,
            icon: Icons.auto_awesome,
            title: '小安助手',
          ),
          _buildMessageItem(
            context,
            icon: Icons.person_outline,
            title: '账户',
            description: '登录IP变更',
            unreadCount: 2,
            date: '11/28',
          ),
          _buildMessageItem(
            context,
            icon: Icons.chat_bubble_outline,
            title: '广场',
            unreadCount: 14,
            date: '10/08',
          ),
          _buildMessageItem(
            context,
            icon: Icons.calendar_today,
            title: '营销与活动',
            description: 'U本位合约强制平仓通知',
            unreadCount: 35,
            date: '06/17',
          ),
          _buildMessageItem(
            context,
            icon: Icons.link,
            title: '交易',
            description: '暂无新的消息',
          ),
        ],
      ),
    );
  }

  /// 构建消息项
  Widget _buildMessageItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? description,
    int? unreadCount,
    String? date,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: description != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
      trailing: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unreadCount != null && unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (date != null) ...[
              if (unreadCount != null && unreadCount > 0)
                const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      onTap: () {
        // TODO: 跳转到消息详情
      },
    );
  }
}
