import 'package:flutter/material.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'widgets.dart';

/// 管理账户页面
class ManageAccountScreen extends StatelessWidget {
  const ManageAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingScreen(
      title: '管理账户',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountOptionCard(
                title: '禁用账户',
                description: '一旦账户禁用，大多数操作都会受限，例如登录和交易等。您可以随时选择解锁该账户。本操作不会删除您的账户。',
                onTap: () => _showDisableAccountDialog(context),
              ),
              const SizedBox(height: 24),
              AccountOptionCard(
                title: '删除账户',
                description: '请注意，账户删除后无法恢复。一旦删除，将无法访问账户或查看交易历史记录。此外，若尝试创建新账户，您的身份认证可能有所延迟。',
                onTap: () => _showDeleteAccountConfirm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示禁用账户确认对话框
  void _showDisableAccountDialog(BuildContext context) {
    MessageService.confirm(
      title: '禁用账户',
      message: '您确定要禁用账户吗？一旦账户禁用，大多数操作都会受限，例如登录和交易等。您可以随时选择解锁该账户。本操作不会删除您的账户。',
      confirmText: '禁用',
      confirmColor: Colors.orange,
      onConfirm: () {
        // TODO: 处理禁用账户操作
      },
    );
  }

  /// 显示删除账户确认对话框
  void _showDeleteAccountConfirm(BuildContext context) {
    MessageService.confirm(
      title: '删除账户',
      message: '您确定要删除账户吗？此操作不可恢复，删除后将无法访问账户或查看交易历史记录。',
      confirmText: '删除',
      confirmColor: Colors.red,
      onConfirm: () {
        // TODO: 处理删除账户操作
      },
    );
  }
}
