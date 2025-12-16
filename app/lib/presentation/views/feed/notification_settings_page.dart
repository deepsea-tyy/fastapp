import 'package:flutter/material.dart';

/// 推送管理页面
///
/// 管理各种推送通知设置
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // 互动通知设置
  bool _likeNotification = false;
  bool _replyNotification = false;
  bool _newFollowNotification = false;
  bool _mentionNotification = false;

  // 内容通知设置
  bool _contentUpdateNotification = true;
  String _contentFrequency = '较少';

  // 其他通知设置
  bool _squareSecretaryNotification = true;
  bool _binanceNewsNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '推送管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // 互动通知
          _buildSectionHeader('互动通知'),
          _buildSwitchTile(
            title: '赞',
            value: _likeNotification,
            onChanged: (value) {
              setState(() {
                _likeNotification = value;
              });
            },
          ),
          _buildSwitchTile(
            title: '回复',
            value: _replyNotification,
            onChanged: (value) {
              setState(() {
                _replyNotification = value;
              });
            },
          ),
          _buildSwitchTile(
            title: '新增关注',
            value: _newFollowNotification,
            onChanged: (value) {
              setState(() {
                _newFollowNotification = value;
              });
            },
          ),
          _buildSwitchTile(
            title: '@提到',
            value: _mentionNotification,
            onChanged: (value) {
              setState(() {
                _mentionNotification = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // 内容通知
          _buildSectionHeader('内容通知'),
          _buildSwitchTile(
            title: '内容更新通知',
            subtitle: '您将收到来自创作者的推送通知',
            value: _contentUpdateNotification,
            onChanged: (value) {
              setState(() {
                _contentUpdateNotification = value;
              });
            },
          ),
          _buildNavigationTile(
            title: '频率',
            trailing: _contentFrequency,
            onTap: () {
              _showFrequencySelector();
            },
          ),
          _buildNavigationTile(
            title: '管理创作者通知',
            onTap: () {
              // TODO: 导航到管理创作者通知页面
            },
          ),

          const SizedBox(height: 24),

          // 其他通知
          _buildSectionHeader('其他通知'),
          _buildSwitchTile(
            title: '广场小秘书通知',
            value: _squareSecretaryNotification,
            onChanged: (value) {
              setState(() {
                _squareSecretaryNotification = value;
              });
            },
          ),
          _buildSwitchTile(
            title: '币安新闻通知',
            value: _binanceNewsNotification,
            onChanged: (value) {
              setState(() {
                _binanceNewsNotification = value;
              });
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 分组标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 开关项
  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  /// 导航项
  Widget _buildNavigationTile({
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
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
              size: 24,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '选择推送频率',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildFrequencyOption('较多'),
              _buildFrequencyOption('适中'),
              _buildFrequencyOption('较少'),
              const SizedBox(height: 8),
            ],
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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                frequency,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? Colors.orange.shade600 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Colors.orange.shade600,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
