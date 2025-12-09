import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/utils/routes/routes.dart';

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
                    '账户中心',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              // 用户名
              Expanded(
                child: Text(
                  'User-92084',
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
            '589772405',
            Icons.copy,
            onIconTap: () {
              Clipboard.setData(const ClipboardData(text: '589772405'));
              MessageService.snackBar('ID已复制');
            },
          ),
          const SizedBox(height: 12),
          // 注册信息
          _buildInfoRow(
            context,
            '注册信息',
            '17612870893',
            Icons.visibility,
            onIconTap: () {
              // TODO: 切换显示/隐藏
            },
          ),
        ],
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
            // TODO: 跳转到VIP特权页面
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.person,
          title: '身份认证',
          trailing: _buildStatusTag('已认证', Colors.green[300]!),
          onTap: () {
            // TODO: 跳转到身份认证页面
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.lock,
          title: '账户安全',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 跳转到账户安全页面
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
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 构建状态标签
  Widget _buildStatusTag(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final userStore = getIt<UserStore>();
                await userStore.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.home,
                    (route) => false,
                  );
                }
              },
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
