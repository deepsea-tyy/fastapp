import 'package:flutter/material.dart';

/// 通知偏好设置页面
class MessageSettingScreen extends StatefulWidget {
  const MessageSettingScreen({super.key});

  @override
  State<MessageSettingScreen> createState() => _MessageSettingScreenState();
}

class _MessageSettingScreenState extends State<MessageSettingScreen> {
  bool _marketingActivities = false;
  bool _transactions = false;
  bool _priceAlerts = true;
  bool _account = true;
  bool _feedbackSuggestions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和描述
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '消息设置',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            _buildToggleItem(
              context,
              '营销与活动',
              _marketingActivities,
              (value) => setState(() => _marketingActivities = value),
            ),
            _buildToggleItem(
              context,
              '交易',
              _transactions,
              (value) => setState(() => _transactions = value),
            ),
            _buildToggleItem(
              context,
              '价格提醒',
              _priceAlerts,
              (value) => setState(() => _priceAlerts = value),
            ),
            _buildToggleItem(
              context,
              '账户',
              _account,
              (value) => setState(() => _account = value),
            ),
            _buildToggleItem(
              context,
              '反馈与产品建议',
              _feedbackSuggestions,
              (value) => setState(() => _feedbackSuggestions = value),
            ),
            _buildNavigationItemWithValue(
              context,
              '订单交易推送',
              '自动订单推送设置',
              null,
              onTap: () {
                // TODO: 跳转到订单交易推送设置
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(String title) {
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

  /// 构建开关项
  Widget _buildToggleItem(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Transform.scale(
        scale: 0.7,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.amber,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  /// 构建导航项
  Widget _buildNavigationItem(
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

  /// 构建带值的导航项
  Widget _buildNavigationItemWithValue(
    BuildContext context,
    String title,
    String? subtitle,
    String? value, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) ...[
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
