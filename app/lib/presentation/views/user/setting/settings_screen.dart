import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'widgets.dart';

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
            SettingAppBar(title: '设置'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
          SectionHeader(title: '通用'),
          SettingItem(title: '通知偏好', onTap: () {}),
          SettingItemWithValue(
            title: '币种',
            value: 'CNY',
            onTap: () {},
          ),
          SettingItemWithValue(
            title: '语言',
            value: _getLanguageDisplayName(languageStore.locale),
            onTap: () {},
          ),
          SettingItem(title: '提现地址', onTap: () {}),
          SettingItem(title: '悬浮窗设置', onTap: () {}),
          SettingItem(title: '使用 BNB', onTap: () {}),

          SectionHeader(title: '主题'),
          SettingItemWithValue(
            title: '主题',
            value: '跟随系统',
            onTap: () {},
          ),
          SettingItem(
            title: '颜色配置',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward, size: 18.0),
                const SizedBox(width: 8.0),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {},
          ),
          SettingItemWithValue(
            title: '涨跌幅与图表时区',
            value: '近24小时',
            onTap: () {},
          ),

          SectionHeader(title: '支付方式'),
          SettingItemWithValue(
            title: '默认支付币种',
            value: 'CNY',
            onTap: () {},
          ),
          SettingItem(title: '支付方式', onTap: () {}),

          SectionHeader(title: '其他'),
          SettingItemWithValue(
            title: '清空缓存',
            value: '327.98MB',
            onTap: () {},
          ),
          SettingItem(title: '帮助与支持', onTap: () {}),
          SettingItem(title: 'Cookie 设置', onTap: () {}),
          SettingItem(title: '隐私中心', onTap: () {}),
          SettingItem(title: '关于我们', onTap: () {}),
          SettingItem(
            title: '检查更新',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  '2.101.7',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Icon(Icons.chevron_right),
              ],
            ),
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
