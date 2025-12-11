import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'widgets.dart';

/// 账户安全页面
class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingScreen(
      title: '账户安全',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 双重验证（2FA）部分
            _build2FASection(context),
            
            // 其他安全设置
            _buildSecuritySettingsSection(context),
          ],
        ),
      ),
    );
  }

  /// 构建双重验证（2FA）部分
  Widget _build2FASection(BuildContext context) {
    final userStore = getIt<UserStore>();
    
    return Observer(
      builder: (_) {
        final user = userStore.currentUser;
        
        // 判断2FA是否已设置（is_google2fa != 0 表示已设置）
        final isGoogle2faEnabled = user?.isGoogle2fa != null && user?.isGoogle2fa != 0;
        
        // 判断手机是否已设置（mobile 有值表示已设置）
        final isMobileEnabled = user?.mobile != null && user?.mobile?.isNotEmpty == true;
        
        // 判断邮箱是否已设置（email 有值表示已设置）
        final isEmailEnabled = user?.email != null && user?.email?.isNotEmpty == true;
        
        // 判断密码是否已设置（is_password == 1 表示已设置）
        final isPasswordEnabled = user?.isPassword != null && user?.isPassword == 1;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '双重验证 (2FA)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '为保障账户安全,请至少启用两种双重身份验证形式。',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              // 2FA选项列表
              const SizedBox(height: 12),
              _build2FAOption(
                context,
                icon: Icons.security,
                title: '身份验证器App',
                isEnabled: isGoogle2faEnabled,
                onTap: () {
                  Navigator.of(context).pushNamed('/authenticator-app');
                },
              ),
              const SizedBox(height: 12),
              _build2FAOption(
                context,
                icon: Icons.email,
                title: '邮箱',
                isEnabled: isEmailEnabled,
                onTap: () {
                  Navigator.of(context).pushNamed('/email-binding');
                },
              ),
              const SizedBox(height: 12),
              _build2FAOption(
                context,
                icon: Icons.lock,
                title: '密码',
                isEnabled: isPasswordEnabled,
                onTap: () {
                  Navigator.of(context).pushNamed('/password-setting');
                },
              ),
              const SizedBox(height: 12),
              _build2FAOption(
                context,
                icon: Icons.phone,
                title: '手机',
                isEnabled: isMobileEnabled,
                onTap: () {
                  Navigator.of(context).pushNamed('/mobile-binding');
                },
              ),
              const SizedBox(height: 16),
              // 分割线
              Divider(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建2FA选项
  Widget _build2FAOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool isRecommended = false,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return SettingCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  StatusTag(text: subtitle, color: Colors.amber[300]!),
                ],
              ],
            ),
          ),
          if (isEnabled)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            )
          else
            Text(
              '未设置',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
        ),
      ),
    );
  }

  /// 构建安全设置部分
  Widget _buildSecuritySettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SettingItem(
            title: '账户绑定',
            onTap: () {
              Navigator.of(context).pushNamed('/account-binding');
            },
          ),
          const SizedBox(height: 16),
          SettingItem(
            title: '管理账户',
            onTap: () {
              Navigator.of(context).pushNamed('/manage-account');
            },
          ),
          SettingItem(
            title: '账户活动',
            onTap: () {
              Navigator.of(context).pushNamed('/account-activity');
            },
          ),
        ],
      ),
    );
  }
}

