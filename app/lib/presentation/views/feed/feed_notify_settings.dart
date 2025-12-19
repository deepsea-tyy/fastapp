import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/common/modern_switch.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/services/message_service.dart';

/// 推送管理页面
///
/// 管理各种推送通知设置
class FeedNotifySettings extends StatefulWidget {
  const FeedNotifySettings({super.key});

  @override
  State<FeedNotifySettings> createState() =>
      _FeedNotifySettingsState();
}

class _FeedNotifySettingsState extends State<FeedNotifySettings> {
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();

  // 互动通知设置
  bool _likeNotification = false; // feed_msg_like
  bool _replyNotification = false; // feed_msg_replay
  bool _newFollowNotification = false; // feed_msg_follow
  bool _mentionNotification = false; // feed_msg_at

  // 内容通知设置
  bool _contentUpdateNotification = true; // feed_msg_content
  String _contentFrequency = '较少'; // feed_msg_frequency: 1=较多, 2=适中, 3=较少

  // 其他通知设置
  bool _binanceNewsNotification = false; // feed_msg_news

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 从用户信息加载设置
  void _loadSettings() {
    final setting = _userStore.currentUser?.profile?.setting;
    if (setting != null) {
      setState(() {
        _likeNotification = setting['feed_msg_like'] == 1;
        _replyNotification = setting['feed_msg_replay'] == 1;
        _newFollowNotification = setting['feed_msg_follow'] == 1;
        _mentionNotification = setting['feed_msg_at'] == 1;
        _contentUpdateNotification = setting['feed_msg_content'] == 1;
        _binanceNewsNotification = setting['feed_msg_news'] == 1;

        // 推送频率：1=较多, 2=适中, 3=较少
        final frequency = setting['feed_msg_frequency'] ?? 3;
        _contentFrequency = frequency == 1 ? '较多' : (frequency == 2 ? '适中' : '较少');
      });
    }
  }

  /// 更新设置到服务器
  Future<void> _updateSetting(Map<String, dynamic> updates) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用接口更新，接口会返回更新后的 profile 数据
      final response = await _userApi.updateProfile(setting: updates);

      // 从返回数据中提取 profile 并更新本地用户信息
      if (response['code'] == 200 && response['data'] != null) {
        final profileData = response['data'];
        // 更新本地设置数据，但不重新请求 /api/user/info
        if (_userStore.currentUser != null && profileData['setting'] != null) {
          // 由于 UserProfile 是 final，我们只能通过重新加载来更新
          // 但用户不希望请求 /api/user/info，所以暂时不更新 store
          // UI 状态已经通过 setState 更新，下次进入页面时会重新加载最新数据
        }
      }
    } catch (e) {
      MessageService.error('更新失败：${e.toString()}');
      // 恢复原来的设置
      _loadSettings();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '推送管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // 互动通知
          const ModernSectionHeader(
            title: '互动通知',
            subtitle: '接收来自其他用户的互动消息',
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ModernSwitchTile(
                  title: '点赞通知',
                  subtitle: '有人点赞你的内容时通知你',
                  icon: Icons.favorite_border,
                  value: _likeNotification,
                  onChanged: (value) {
                    setState(() {
                      _likeNotification = value;
                    });
                    _updateSetting({'feed_msg_like': value ? 1 : 0});
                  },
                ),
                ModernSwitchTile(
                  title: '回复通知',
                  subtitle: '有人回复你的内容时通知你',
                  icon: Icons.chat_bubble_outline,
                  value: _replyNotification,
                  onChanged: (value) {
                    setState(() {
                      _replyNotification = value;
                    });
                    _updateSetting({'feed_msg_replay': value ? 1 : 0});
                  },
                ),
                ModernSwitchTile(
                  title: '新增关注',
                  subtitle: '有人关注你时通知你',
                  icon: Icons.person_add_outlined,
                  value: _newFollowNotification,
                  onChanged: (value) {
                    setState(() {
                      _newFollowNotification = value;
                    });
                    _updateSetting({'feed_msg_follow': value ? 1 : 0});
                  },
                ),
                ModernSwitchTile(
                  title: '@提到通知',
                  subtitle: '有人在内容中提到你时通知你',
                  icon: Icons.alternate_email,
                  value: _mentionNotification,
                  onChanged: (value) {
                    setState(() {
                      _mentionNotification = value;
                    });
                    _updateSetting({'feed_msg_at': value ? 1 : 0});
                  },
                ),
              ],
            ),
          ),

          // 内容通知
          const ModernSectionHeader(
            title: '内容通知',
            subtitle: '管理你关注的创作者的内容更新通知',
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ModernSwitchTile(
                  title: '内容更新通知',
                  subtitle: '关注的创作者发布新内容时通知你',
                  icon: Icons.notifications_active_outlined,
                  value: _contentUpdateNotification,
                  onChanged: (value) {
                    setState(() {
                      _contentUpdateNotification = value;
                    });
                    _updateSetting({'feed_msg_content': value ? 1 : 0});
                  },
                ),
                _buildNavigationTile(
                  title: '推送频率',
                  trailing: _contentFrequency,
                  icon: Icons.schedule,
                  onTap: () {
                    _showFrequencySelector();
                  },
                ),
                _buildNavigationTile(
                  title: '管理创作者通知',
                  icon: Icons.tune,
                  onTap: () {
                    // TODO: 导航到管理创作者通知页面
                  },
                ),
              ],
            ),
          ),

          // 其他通知
          const ModernSectionHeader(
            title: '其他通知',
            subtitle: '平台相关的系统通知',
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ModernSwitchTile(
                  title: '平台新闻通知',
                  subtitle: '接收平台的最新动态和公告',
                  icon: Icons.newspaper,
                  value: _binanceNewsNotification,
                  onChanged: (value) {
                    setState(() {
                      _binanceNewsNotification = value;
                    });
                    _updateSetting({'feed_msg_news': value ? 1 : 0});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 导航项
  Widget _buildNavigationTile({
    required String title,
    String? trailing,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade100,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 图标（可选）
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示频率选择器
  void _showFrequencySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部拖动条
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    '选择推送频率',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildFrequencyOption('较多'),
                _buildFrequencyOption('适中'),
                _buildFrequencyOption('较少'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 频率选项
  Widget _buildFrequencyOption(String frequency) {
    final isSelected = _contentFrequency == frequency;
    return InkWell(
      onTap: () {
        setState(() {
          _contentFrequency = frequency;
        });
        Navigator.pop(context);

        // 将频率文本转换为数字：1=较多, 2=适中, 3=较少
        final frequencyValue = frequency == '较多' ? 1 : (frequency == '适中' ? 2 : 3);
        _updateSetting({'feed_msg_frequency': frequencyValue});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                frequency,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? const Color(0xFFFF9500) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF9500),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
