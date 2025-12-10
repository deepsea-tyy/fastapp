import 'package:flutter/material.dart';
import 'widgets.dart';

/// 账户绑定页面
class AccountBindingScreen extends StatelessWidget {
  const AccountBindingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SettingAppBar(title: '账户绑定'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 页面描述
                      Center(
                        child: Text(
                          '将您的账户与第三方账户关联。',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Google登录绑定
                      _buildBindingOption(
                        context,
                        iconWidget: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        title: '使用Google登录',
                        subtitle: 'ty*****@gmail.com',
                        isBound: true,
                        onButtonTap: () {
                          // TODO: 处理解除Google关联
                        },
                      ),
                      const SizedBox(height: 12),
                      // Apple登录绑定
                      _buildBindingOption(
                        context,
                        iconWidget: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: '使用Apple登录',
                        subtitle: '① 您的设备不支持该功能。',
                        isBound: false,
                        isDisabled: true,
                        onButtonTap: null,
                      ),
                      const SizedBox(height: 12),
                      // Telegram绑定
                      _buildBindingOption(
                        context,
                        iconWidget: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0088CC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: '关联 Telegram',
                        subtitle: '@deepsea159',
                        isBound: true,
                        onButtonTap: () {
                          // TODO: 处理解除Telegram关联
                        },
                      ),
                      const SizedBox(height: 32),
                      // 查看账户活动区域
                      _buildAccountActivitySection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建绑定选项
  Widget _buildBindingOption(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String title,
    required String subtitle,
    required bool isBound,
    bool isDisabled = false,
    VoidCallback? onButtonTap,
  }) {
    return SettingCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 图标
          iconWidget ??
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon ?? Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
          const SizedBox(width: 12),
          // 标题和副标题
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 按钮
          ElevatedButton(
            onPressed: isDisabled ? null : onButtonTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isBound ? '解除关联' : '关联',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账户活动区域
  Widget _buildAccountActivitySection(BuildContext context) {
    return SettingCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '查看账户活动',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '点击以下链接，即可查看所有账户活动。',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/account-activity');
            },
            child: Text(
              '账户活动',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
