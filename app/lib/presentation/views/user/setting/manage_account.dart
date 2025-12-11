import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/user/setting/verification_dialog.dart';
import 'package:fastapp/presentation/views/main/main_screen.dart';
import 'widgets.dart';

/// 管理账户页面
class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  final UserApi _userApi = getIt<UserApi>();
  final UserStore _userStore = getIt<UserStore>();
  bool _isLoading = false;

  static const Duration _cacheClearDelay = Duration(milliseconds: 500);

  void _handleAccountAction({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required Future<Map<String, dynamic>> Function(String, String?, String?) apiCall,
    required String successMessage,
  }) {
    if (_isLoading) return;
    
    VerificationDialog.show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      confirmColor: confirmColor,
      onConfirm: ({required String password, String? google2faCode, String? vcode}) async {
        await _executeAccountOperation(
          () => apiCall(password, google2faCode, vcode),
          successMessage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseSettingScreen(
      title: '管理账户',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountOptionCard(
              title: '禁用账户',
              description: '一旦账户禁用，大多数操作都会受限，例如登录和交易等。您可以随时选择解锁该账户。本操作不会删除您的账户。',
              onTap: _isLoading ? null : () => _handleAccountAction(
                title: '禁用账户',
                message: '为了账户安全，请先验证您的身份。一旦账户禁用，大多数操作都会受限，例如登录和交易等。您可以随时选择解锁该账户。本操作不会删除您的账户。',
                confirmText: '禁用',
                confirmColor: Colors.orange,
                apiCall: (p, g, v) => _userApi.disableAccount(
                  password: p,
                  google2faCode: g,
                  vcode: v,
                ),
                successMessage: '账户已禁用',
              ),
            ),
            const SizedBox(height: 24),
            AccountOptionCard(
              title: '删除账户',
              description: '请注意，账户删除后无法恢复。一旦删除，将无法访问账户或查看交易历史记录。此外，若尝试创建新账户，您的身份认证可能有所延迟。',
              onTap: _isLoading ? null : () => _handleAccountAction(
                title: '删除账户',
                message: '为了账户安全，请先验证您的身份。请注意，账户删除后无法恢复。一旦删除，将无法访问账户或查看交易历史记录。',
                confirmText: '删除',
                confirmColor: Colors.red,
                apiCall: (p, g, v) => _userApi.deleteAccount(
                  password: p,
                  google2faCode: g,
                  vcode: v,
                ),
                successMessage: '账户已删除',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeAccountOperation(
    Future<Map<String, dynamic>> Function() apiCall,
    String successMessage,
  ) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await apiCall();
      final code = response['code'] as int?;
      final message = response['message'] as String? ?? 
          (code == 200 ? successMessage : '操作失败');
      
      if (code == 200) {
        MessageService.success(message);
        await _navigateToHomeAndClearCache();
      } else {
        MessageService.error(message);
      }
    } catch (e) {
      if (mounted) {
        MessageService.error(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToHomeAndClearCache() async {
    if (!mounted) return;
    
    try {
      // 先清除登录状态（logout 会在 finally 中清除状态，即使 API 失败）
      await _userStore.logout();
      
      // 然后导航到首页
      final navigator = Navigator.of(context, rootNavigator: true);
      await navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
      
      // 最后异步清除设备ID等其他缓存
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await Future.delayed(_cacheClearDelay);
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('device_id');
        } catch (e) {
          if (kDebugMode) {
            print('清除缓存失败: $e');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('导航失败: $e');
      }
    }
  }
}
