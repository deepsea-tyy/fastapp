import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/domain/entity/user/user.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets.dart';

/// 账户中心页面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 常量配置
  static const _cardMargin = EdgeInsets.all(16.0);
  static const _cardPadding = EdgeInsets.all(16.0);
  static const _avatarSize = 50.0;
  static const _iconSize = 20.0;

  // 是否显示完整的手机号
  bool _showMobile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SettingAppBar(title: '账户中心'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUserProfileCard(context),
                    _buildFeatureList(context),
                  ],
                ),
              ),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  /// 构建用户资料卡片
  Widget _buildUserProfileCard(BuildContext context) {
    final userStore = getIt<UserStore>();
    
    return Observer(
      builder: (_) {
        final user = userStore.currentUser;
        if (user == null) {
          return Container(
            margin: _cardMargin,
            padding: _cardPadding,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        final theme = Theme.of(context);
        final displayName = _getDisplayName(user);
        final userNo = user.no?.toString() ?? user.id.toString();
        
        return Container(
          margin: _cardMargin,
          padding: _cardPadding,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAvatar(user.profile?.avatar),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: _iconSize),
                    onPressed: () {
                      _showEditNicknameDialog(context, userStore, user);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'ID',
                userNo,
                Icons.copy,
                onIconTap: () {
                  Clipboard.setData(ClipboardData(text: userNo));
                  MessageService.snackBar('ID已复制');
                },
              ),
              if (user.mobile?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  '注册信息',
                  _showMobile ? user.mobile! : _maskMobile(user.mobile!),
                  _showMobile ? Icons.visibility_off : Icons.visibility,
                  onIconTap: () {
                    setState(() {
                      _showMobile = !_showMobile;
                    });
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 获取显示名称
  String _getDisplayName(User user) {
    if (user.profile?.nickname?.isNotEmpty == true) {
      return user.profile!.nickname!;
    }
    if (user.username?.isNotEmpty == true) {
      return user.username!;
    }
    return user.mobile ?? user.email ?? '未设置';
  }

  /// 隐藏手机号中间部分
  String _maskMobile(String mobile) {
    if (mobile.length <= 7) {
      return mobile;
    }
    // 显示前3位和后4位，中间用*代替
    final prefix = mobile.substring(0, 3);
    final suffix = mobile.substring(mobile.length - 4);
    final middle = '*' * (mobile.length - 7);
    return '$prefix$middle$suffix';
  }
  
  /// 构建头像
  Widget _buildAvatar(String? avatarUrl) {
    final defaultAvatar = Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
    );

    if (avatarUrl?.isNotEmpty != true) return defaultAvatar;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: _avatarSize,
        height: _avatarSize,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: _avatarSize,
          height: _avatarSize,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => defaultAvatar,
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    required VoidCallback onIconTap,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
        ),
        IconButton(
          icon: Icon(icon, size: 18),
          onPressed: onIconTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  /// 构建功能列表
  Widget _buildFeatureList(BuildContext context) {
    final userStore = getIt<UserStore>();
    
    return Observer(
      builder: (_) {
        final isKycVerified = userStore.currentUser?.isKyc == 1;
        final theme = Theme.of(context);
        
        return Column(
          children: [
            _buildFeatureItem(
              context,
              icon: Icons.diamond,
              title: 'VIP特权',
              trailing: _buildStatusTag('普通用户', Colors.orange[300]!),
              onTap: () => Navigator.of(context).pushNamed(Routes.vipPrivilege),
            ),
            _buildFeatureItem(
              context,
              icon: Icons.person,
              title: '身份认证',
              trailing: _buildStatusTag(
                isKycVerified ? '已认证' : '未认证',
                isKycVerified ? Colors.green[300]! : Colors.grey[400]!,
              ),
              onTap: () => _navigateToIdentityVerification(context, userStore),
            ),
            _buildFeatureItem(
              context,
              icon: Icons.lock,
              title: '账户安全',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(Routes.accountSecurity),
            ),
          ],
        );
      },
    );
  }

  /// 导航到身份认证页面
  Future<void> _navigateToIdentityVerification(BuildContext context, UserStore userStore) async {
    await Navigator.of(context).pushNamed(Routes.identityVerification);
    if (context.mounted) {
      await userStore.getUserInfo();
    }
  }

  /// 构建功能项
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return SettingItem(
      title: title,
      leadingIcon: icon,
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 构建状态标签
  Widget _buildStatusTag(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusTag(text: text, color: color),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  /// 构建退出按钮
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: _cardMargin,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleLogout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            '退出登录',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// 处理退出登录
  void _handleLogout(BuildContext context) {
    MessageService.confirm(
      title: '确认退出',
      message: '确定要退出登录吗？',
      confirmText: '确定',
      cancelText: '取消',
      confirmColor: Colors.red,
      onConfirm: () async {
        final userStore = getIt<UserStore>();
        await userStore.logout();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.home,
            (route) => false,
          );
        }
      },
    );
  }

  /// 显示编辑昵称对话框
  Future<void> _showEditNicknameDialog(BuildContext context, UserStore userStore, User user) async {
    final result = await MessageService.inputDialog(
      title: '编辑昵称',
      fields: [
        InputField(
          label: '昵称',
          hintText: '请输入昵称',
          initialValue: user.profile?.nickname ?? '',
          maxLength: 60,
          autofocus: true,
          validator: (value) {
            if (value.isEmpty) {
              MessageService.snackBar('昵称不能为空');
              return false;
            }
            if (value.contains(' ')) {
              MessageService.snackBar('昵称不能包含空格');
              return false;
            }
            return true;
          },
        ),
      ],
    );

    if (result != null && result['昵称'] != null) {
      final nickname = result['昵称']!.trim();
      await _updateNickname(context, userStore, nickname);
    }
  }

  /// 更新昵称
  Future<void> _updateNickname(BuildContext context, UserStore userStore, String nickname) async {
    try {
      await userStore.updateNickname(nickname);
    } catch (e) {
      if (context.mounted) {
        MessageService.snackBar('更新失败: ${e.toString()}');
      }
    }
  }
}
