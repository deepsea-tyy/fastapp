import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets.dart';

/// 账户中心页面
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SettingAppBar(title: '账户中心'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 用户资料卡片
                    _buildUserProfileCard(context),
                    
                    // 功能列表
                    _buildFeatureList(context),
                  ],
                ),
              ),
            ),
            // 退出按钮
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
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 显示名称：优先显示昵称，如果没有则显示用户名
        final displayName = user.profile?.nickname?.isNotEmpty == true
            ? user.profile!.nickname!
            : user.username;
        
        // 用户编号（no字段）
        final userNo = user.no?.toString() ?? user.id.toString();
        
        // 手机号（注册信息）
        final mobile = user.mobile ?? '';
        
        return Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              // 头像和用户名
              Row(
                children: [
                  // 头像
                  _buildAvatar(user.profile?.avatar),
                  const SizedBox(width: 12),
                  // 用户名
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // 编辑图标
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      // TODO: 编辑用户信息
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ID
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
              const SizedBox(height: 12),
              // 注册信息（手机号）
              if (mobile.isNotEmpty)
                _buildInfoRow(
                  context,
                  '注册信息',
                  mobile,
                  Icons.visibility,
                  onIconTap: () {
                    // TODO: 切换显示/隐藏
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  
  /// 构建头像
  Widget _buildAvatar(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 30,
        color: Colors.grey[600],
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
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
    return Column(
      children: [
        _buildFeatureItem(
          context,
          icon: Icons.diamond,
          title: 'VIP特权',
          trailing: _buildStatusTag('普通用户', Colors.orange[300]!),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.vipPrivilege);
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.person,
          title: '身份认证',
          trailing: _buildStatusTag('已认证', Colors.green[300]!),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.identityVerification);
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.lock,
          title: '账户安全',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.accountSecurity);
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.close,
          title: 'Twitter',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '未绑定',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            // TODO: 跳转到Twitter绑定页面
          },
        ),
      ],
    );
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
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _handleLogout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '退出登录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
}
