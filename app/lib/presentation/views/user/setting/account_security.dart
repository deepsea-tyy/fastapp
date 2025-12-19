import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'widgets.dart';

/// 安全设置页面
class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingScreen(
      title: '安全设置',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // 双重验证（2FA）部分
            _build2FASection(context),

            const SizedBox(height: 24),

            // 其他安全设置
            _buildSecuritySettingsSection(context),

            const SizedBox(height: 24),
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

        // 计算已启用的2FA方式数量
        final enabledCount = [isGoogle2faEnabled, isMobileEnabled, isEmailEnabled, isPasswordEnabled]
            .where((enabled) => enabled)
            .length;
        final totalCount = 4;
        final securityLevel = enabledCount >= 2 ? '良好' : enabledCount == 1 ? '一般' : '较弱';
        final securityColor = enabledCount >= 2
            ? Colors.grey.shade700
            : enabledCount == 1
                ? Colors.grey.shade600
                : Colors.grey.shade500;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 区域标题
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '双重验证 (2FA)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '安全等级: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        securityLevel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: securityColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 安全进度卡片
              SettingCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '已启用 $enabledCount/$totalCount 种验证方式',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: securityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$enabledCount/$totalCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: securityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: enabledCount / totalCount,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        color: securityColor,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      enabledCount >= 2
                          ? '您的账户安全性良好,建议继续保持'
                          : '为保障账户安全,建议至少启用两种验证方式',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2FA选项列表
              Text(
                '验证方式',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              _build2FAOption(
                context,
                icon: Icons.verified_user,
                title: '身份验证器App',
                description: '使用Google Authenticator等APP生成动态验证码',
                isEnabled: isGoogle2faEnabled,
                isRecommended: true,
                onTap: () {
                  Navigator.of(context).pushNamed('/authenticator-app');
                },
              ),
              const SizedBox(height: 12),

              _build2FAOption(
                context,
                icon: Icons.email_outlined,
                title: '邮箱验证',
                description: '通过邮箱接收验证码进行身份验证',
                isEnabled: isEmailEnabled,
                onTap: () {
                  Navigator.of(context).pushNamed('/email-binding');
                },
              ),
              const SizedBox(height: 12),

              _build2FAOption(
                context,
                icon: Icons.phone_android,
                title: '手机验证',
                description: '通过手机短信接收验证码进行身份验证',
                isEnabled: isMobileEnabled,
                onTap: () {
                  Navigator.of(context).pushNamed('/mobile-binding');
                },
              ),
              const SizedBox(height: 12),

              _build2FAOption(
                context,
                icon: Icons.lock_outline,
                title: '登录密码',
                description: '设置独立的登录密码保护账户',
                isEnabled: isPasswordEnabled,
                onTap: () {
                  Navigator.of(context).pushNamed('/password-setting');
                },
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
    required String description,
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
            // 图标 - 统一灰色样式
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // 标题和描述
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '推荐',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 状态标识 - 统一样式
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isEnabled)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.grey.shade700,
                      size: 16,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '未设置',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区域标题
          const Text(
            '安全管理',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 安全设置选项
          _buildSecurityOption(
            context,
            icon: Icons.link,
            iconColor: Colors.blue,
            title: '账户绑定',
            description: '管理关联的第三方账户和设备',
            onTap: () {
              Navigator.of(context).pushNamed('/account-binding');
            },
          ),

          const SizedBox(height: 12),

          _buildSecurityOption(
            context,
            icon: Icons.manage_accounts,
            iconColor: Colors.purple,
            title: '管理账户',
            description: '账户信息管理和设置',
            onTap: () {
              Navigator.of(context).pushNamed('/manage-account');
            },
          ),

          const SizedBox(height: 12),

          _buildSecurityOption(
            context,
            icon: Icons.history,
            iconColor: Colors.orange,
            title: '安全记录',
            description: '查看账户登录和安全操作历史',
            onTap: () {
              Navigator.of(context).pushNamed('/account-activity');
            },
          ),
        ],
      ),
    );
  }

  /// 构建安全设置选项
  Widget _buildSecurityOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return SettingCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // 图标 - 统一灰色样式
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // 标题和描述
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 箭头图标
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

