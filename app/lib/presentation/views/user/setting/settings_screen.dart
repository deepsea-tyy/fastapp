import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageStore = getIt<LanguageStore>();

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
                    '设置',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
          // 通用设置
          _buildSectionHeader(context, '通用'),
          _buildMenuItem(
            context,
            '通知偏好',
            onTap: () {},
          ),
          _buildMenuItemWithValue(
            context,
            '币种',
            'CNY',
            onTap: () {},
          ),
          _buildMenuItemWithValue(
            context,
            '语言',
            _getLanguageDisplayName(languageStore.locale),
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            '提现地址',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            '悬浮窗设置',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            '使用 BNB',
            onTap: () {},
          ),

          // 主题设置
          _buildSectionHeader(context, '主题'),
          _buildMenuItemWithValue(
            context,
            '主题',
            '跟随系统',
            onTap: () {},
          ),
          _buildMenuItemWithIcon(
            context,
            '颜色配置',
            Icons.arrow_upward,
            onTap: () {},
          ),
          _buildMenuItemWithValue(
            context,
            '涨跌幅与图表时区',
            '近24小时',
            onTap: () {},
          ),

          // 支付方式
          _buildSectionHeader(context, '支付方式'),
          _buildMenuItemWithValue(
            context,
            '默认支付币种',
            'CNY',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            '支付方式',
            onTap: () {},
          ),

          // 其他
          _buildSectionHeader(context, '其他'),
          _buildMenuItemWithValue(
            context,
            '清空缓存',
            '327.98MB',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            '帮助与支持',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            'Cookie 设置',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            '隐私中心',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            '关于我们',
            onTap: () {},
          ),
          _buildMenuItemWithBadge(
            context,
            '检查更新',
            '2.101.7',
            onTap: () {},
          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildMenuItemWithValue(
    BuildContext context,
    String title,
    String value, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8.0),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuItemWithIcon(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.0),
          const SizedBox(width: 8.0),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuItemWithBadge(
    BuildContext context,
    String title,
    String badge, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            badge,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8.0),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  String _getLanguageDisplayName(String locale) {
    switch (locale) {
      case 'zh':
        return '中文简体';
      case 'zh_TW':
        return '繁體中文';
      case 'en':
        return 'English';
      default:
        return '中文简体';
    }
  }
}
