import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/user/message/activity_screen.dart';
import 'package:fastapp/presentation/views/user/message/notice_screen.dart';
import 'package:fastapp/presentation/views/user/message/message_setting.dart';
import 'package:fastapp/presentation/views/user/setting/account_activity.dart';
import 'package:fastapp/data/network/apis/message/message_notify_api.dart';
import 'package:fastapp/domain/entity/message/unread_statistics.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/core/services/message_service.dart';

/// 消息页面
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageNotifyApi _messageNotifyApi = getIt<MessageNotifyApi>();
  UnreadStatistics _unreadStatistics = UnreadStatistics.empty();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnreadStatistics();
  }

  /// 加载未读统计数据
  Future<void> _loadUnreadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _messageNotifyApi.getUnreadStatistics();
      setState(() {
        _unreadStatistics = UnreadStatistics.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('加载未读统计失败: $e');
    }
  }

  /// 清除所有未读消息
  Future<void> _clearAllUnread() async {
    // 先更新本地数据，给用户即时反馈
    if (mounted) {
      setState(() {
        _unreadStatistics = UnreadStatistics(
          announcement: MessageCategoryStats(
            unreadCount: 0,
            title: _unreadStatistics.announcement.title,
            content: _unreadStatistics.announcement.content,
            lastId: _unreadStatistics.announcement.lastId,
            createdAt: _unreadStatistics.announcement.createdAt,
          ),
          activity: MessageCategoryStats(
            unreadCount: 0,
            title: _unreadStatistics.activity.title,
            content: _unreadStatistics.activity.content,
            lastId: _unreadStatistics.activity.lastId,
            createdAt: _unreadStatistics.activity.createdAt,
          ),
          account: MessageCategoryStats(
            unreadCount: 0,
            title: _unreadStatistics.account.title,
            content: _unreadStatistics.account.content,
            lastId: _unreadStatistics.account.lastId,
            createdAt: _unreadStatistics.account.createdAt,
          ),
          community: MessageCategoryStats(
            unreadCount: 0,
            title: _unreadStatistics.community.title,
            content: _unreadStatistics.community.content,
            lastId: _unreadStatistics.community.lastId,
            createdAt: _unreadStatistics.community.createdAt,
          ),
          funds: MessageCategoryStats(
            unreadCount: 0,
            title: _unreadStatistics.funds.title,
            content: _unreadStatistics.funds.content,
            lastId: _unreadStatistics.funds.lastId,
            createdAt: _unreadStatistics.funds.createdAt,
          ),
          totalUnread: 0,
        );
      });
    }

    // 后台调用清除接口
    try {
      await _messageNotifyApi.clearUnread();
    } catch (e) {
      debugPrint('清除未读失败: $e');
      MessageService.error('清除失败，请重试');
    }
  }

  /// 标记指定分类为已读（不等待加载统计）
  Future<void> _markAsRead(int notifyType, int unreadCount, int lastId) async {
    // 判断是否有未读消息且有有效的消息ID
    if (unreadCount <= 0 || lastId <= 0) {
      return;
    }

    // 先更新本地数据，给用户即时反馈
    _updateLocalUnreadCount(notifyType);

    try {
      // 后台调用 read 接口
      _messageNotifyApi.updateReadStatus(
        notifyType: notifyType,
        notifyId: lastId,
      ).catchError((e) {
        debugPrint('标记已读失败: $e');
        // API 失败时不提示错误，因为本地数据已更新，用户体验不受影响
      });
    } catch (e) {
      debugPrint('标记已读失败: $e');
    }
  }

  /// 更新本地未读数据
  void _updateLocalUnreadCount(int notifyType) {
    if (!mounted) return;

    setState(() {
      // 根据分类类型更新对应的未读数
      switch (notifyType) {
        case 1: // 公告
          _unreadStatistics = UnreadStatistics(
            announcement: MessageCategoryStats(
              unreadCount: 0,
              title: _unreadStatistics.announcement.title,
              content: _unreadStatistics.announcement.content,
              lastId: _unreadStatistics.announcement.lastId,
              createdAt: _unreadStatistics.announcement.createdAt,
            ),
            activity: _unreadStatistics.activity,
            account: _unreadStatistics.account,
            community: _unreadStatistics.community,
            funds: _unreadStatistics.funds,
            totalUnread: _unreadStatistics.totalUnread - _unreadStatistics.announcement.unreadCount,
          );
          break;
        case 2: // 活动
          _unreadStatistics = UnreadStatistics(
            announcement: _unreadStatistics.announcement,
            activity: MessageCategoryStats(
              unreadCount: 0,
              title: _unreadStatistics.activity.title,
              content: _unreadStatistics.activity.content,
              lastId: _unreadStatistics.activity.lastId,
              createdAt: _unreadStatistics.activity.createdAt,
            ),
            account: _unreadStatistics.account,
            community: _unreadStatistics.community,
            funds: _unreadStatistics.funds,
            totalUnread: _unreadStatistics.totalUnread - _unreadStatistics.activity.unreadCount,
          );
          break;
        case 3: // 账户
          _unreadStatistics = UnreadStatistics(
            announcement: _unreadStatistics.announcement,
            activity: _unreadStatistics.activity,
            account: MessageCategoryStats(
              unreadCount: 0,
              title: _unreadStatistics.account.title,
              content: _unreadStatistics.account.content,
              lastId: _unreadStatistics.account.lastId,
              createdAt: _unreadStatistics.account.createdAt,
            ),
            community: _unreadStatistics.community,
            funds: _unreadStatistics.funds,
            totalUnread: _unreadStatistics.totalUnread - _unreadStatistics.account.unreadCount,
          );
          break;
        case 4: // 广场
          _unreadStatistics = UnreadStatistics(
            announcement: _unreadStatistics.announcement,
            activity: _unreadStatistics.activity,
            account: _unreadStatistics.account,
            community: MessageCategoryStats(
              unreadCount: 0,
              title: _unreadStatistics.community.title,
              content: _unreadStatistics.community.content,
              lastId: _unreadStatistics.community.lastId,
              createdAt: _unreadStatistics.community.createdAt,
            ),
            funds: _unreadStatistics.funds,
            totalUnread: _unreadStatistics.totalUnread - _unreadStatistics.community.unreadCount,
          );
          break;
        case 5: // 交易
          _unreadStatistics = UnreadStatistics(
            announcement: _unreadStatistics.announcement,
            activity: _unreadStatistics.activity,
            account: _unreadStatistics.account,
            community: _unreadStatistics.community,
            funds: MessageCategoryStats(
              unreadCount: 0,
              title: _unreadStatistics.funds.title,
              content: _unreadStatistics.funds.content,
              lastId: _unreadStatistics.funds.lastId,
              createdAt: _unreadStatistics.funds.createdAt,
            ),
            totalUnread: _unreadStatistics.totalUnread - _unreadStatistics.funds.unreadCount,
          );
          break;
      }
    });
  }

  /// 显示清除所有未读的确认对话框
  void _showClearAllConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有未读'),
        content: const Text('确定要清除所有分类的未读消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllUnread();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 获取消息描述：优先显示标题，没有标题则显示内容
  String? _getMessageDescription(MessageCategoryStats stats) {
    if (stats.title.isNotEmpty) {
      return stats.title;
    } else if (stats.content.isNotEmpty) {
      return stats.content;
    }
    return null;
  }

  /// 格式化日期
  String? _formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 365) {
        return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
      } else {
        return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      debugPrint('日期格式化失败: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '消息',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: _showClearAllConfirmDialog,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        _buildMessageItem(
                          context,
                          icon: Icons.campaign,
                          title: '公告',
                          description: _getMessageDescription(_unreadStatistics.announcement),
                          date: _formatDate(_unreadStatistics.announcement.createdAt),
                          unreadCount: _unreadStatistics.announcement.unreadCount,
                          notifyType: 1,
                          onTap: () {
                            // 标记已读
                            _markAsRead(
                              1,
                              _unreadStatistics.announcement.unreadCount,
                              _unreadStatistics.announcement.lastId,
                            );
                            // 跳转到列表页
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NoticeScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMessageItem(
                          context,
                          icon: Icons.card_giftcard,
                          title: '活动',
                          description: _getMessageDescription(_unreadStatistics.activity),
                          date: _formatDate(_unreadStatistics.activity.createdAt),
                          unreadCount: _unreadStatistics.activity.unreadCount,
                          notifyType: 2,
                          onTap: () {
                            // 标记已读
                            _markAsRead(
                              2,
                              _unreadStatistics.activity.unreadCount,
                              _unreadStatistics.activity.lastId,
                            );
                            // 跳转到列表页
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ActivityScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMessageItem(
                          context,
                          icon: Icons.person_outline,
                          title: '账户',
                          description: _getMessageDescription(_unreadStatistics.account),
                          unreadCount: _unreadStatistics.account.unreadCount,
                          date: _formatDate(_unreadStatistics.account.createdAt),
                          notifyType: 3,
                          onTap: () {
                            // 标记已读
                            _markAsRead(
                              3,
                              _unreadStatistics.account.unreadCount,
                              _unreadStatistics.account.lastId,
                            );
                            // 跳转到列表页
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AccountActivityScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMessageItem(
                          context,
                          icon: Icons.chat_bubble_outline,
                          title: '广场',
                          description: _getMessageDescription(_unreadStatistics.community),
                          unreadCount: _unreadStatistics.community.unreadCount,
                          date: _formatDate(_unreadStatistics.community.createdAt),
                          notifyType: 4,
                          onTap: () {
                            // 标记已读
                            _markAsRead(
                              4,
                              _unreadStatistics.community.unreadCount,
                              _unreadStatistics.community.lastId,
                            );
                            // TODO: 跳转到广场消息列表
                          },
                        ),
                        _buildMessageItem(
                          context,
                          icon: Icons.link,
                          title: '交易',
                          description: _getMessageDescription(_unreadStatistics.funds),
                          unreadCount: _unreadStatistics.funds.unreadCount > 0
                              ? _unreadStatistics.funds.unreadCount
                              : null,
                          date: _formatDate(_unreadStatistics.funds.createdAt),
                          notifyType: 5,
                          onTap: () {
                            // 标记已读
                            _markAsRead(
                              5,
                              _unreadStatistics.funds.unreadCount,
                              _unreadStatistics.funds.lastId,
                            );
                            // TODO: 跳转到交易消息列表
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
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
    required int notifyType,
    VoidCallback? onTap,
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
      onTap: onTap,
    );
  }
}
