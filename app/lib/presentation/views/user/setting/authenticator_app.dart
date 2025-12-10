import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/domain/repository/user/user_repository.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'widgets.dart';

/// 身份验证器App验证页面
class AuthenticatorAppScreen extends StatefulWidget {
  const AuthenticatorAppScreen({super.key});

  @override
  State<AuthenticatorAppScreen> createState() => _AuthenticatorAppScreenState();
}

class _AuthenticatorAppScreenState extends State<AuthenticatorAppScreen> {
  final UserStore _userStore = getIt<UserStore>();
  final UserRepository _userRepository = getIt<UserRepository>();
  final TextEditingController _codeController = TextEditingController();
  
  String? _secretKey;
  String? _qrcodeBase64;
  bool _isLoading = false;
  bool _isLoadingQrcode = false;

  // 间距常量
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 12.0;
  static const double _spacingLarge = 16.0;
  static const double _pagePadding = 12.0;

  // 输入框边框样式
  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  );

  // 验证码输入框装饰
  InputDecoration _getCodeInputDecoration() {
    return InputDecoration(
      hintText: '请输入6位验证码',
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: _spacingLarge, vertical: 14),
      counterText: '',
    );
  }

  // 验证码输入框样式
  static const _codeTextStyle = TextStyle(
    fontSize: 20,
    letterSpacing: 6,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  @override
  void initState() {
    super.initState();
    _loadQrcode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 判断是否已启用2FA
  bool get _isGoogle2faEnabled {
    final user = _userStore.currentUser;
    return user?.isGoogle2fa == 1;
  }

  /// 加载二维码
  Future<void> _loadQrcode() async {
    if (_isGoogle2faEnabled) return;
    
    setState(() => _isLoadingQrcode = true);

    try {
      final data = await _userRepository.getGoogle2faQrcode();
      if (!mounted) return;
      setState(() {
        _secretKey = data['google2fa'] as String?;
        _qrcodeBase64 = data['qrcode'] as String?;
        _isLoadingQrcode = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingQrcode = false);
      MessageService.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SettingAppBar(title: '身份验证器App验证'),
            Expanded(
              child: Observer(
                builder: (_) => _isGoogle2faEnabled 
                    ? _buildEnabledView(context) 
                    : _buildSetupView(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建未设置状态下的设置界面
  Widget _buildSetupView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityTip(context),
          const SizedBox(height: _spacingMedium),
          _buildDescriptionText(context),
          const SizedBox(height: _spacingMedium),
          ..._buildSteps(context),
          const SizedBox(height: _spacingMedium),
          _buildQRCodeCard(context),
          const SizedBox(height: 10),
          _buildVerificationCodeInput(context),
          const SizedBox(height: _spacingMedium),
          _buildActionButton(
            text: '完成设置',
            onPressed: () => _handleSetup(context),
          ),
        ],
      ),
    );
  }

  /// 构建已设置状态下的界面
  Widget _buildEnabledView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityTip(context),
          const SizedBox(height: _spacingMedium),
          _buildAuthenticatorAppCard(context, '2025年3月23日'),
          const SizedBox(height: _spacingMedium),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 构建说明文字
  Widget _buildDescriptionText(BuildContext context) {
    return Text(
      '使用身份验证器App可以增强账户安全性。请按照以下步骤设置：',
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  /// 构建步骤列表
  List<Widget> _buildSteps(BuildContext context) {
    const steps = [
      (1, '下载身份验证器App', '在手机上下载并安装Google Authenticator、Microsoft Authenticator或其他支持TOTP的身份验证器应用。'),
      (2, '扫描二维码', '使用身份验证器App扫描下方二维码，或手动输入密钥。'),
      (3, '输入验证码', '在身份验证器App中获取6位验证码，并在下方输入框中输入以完成设置。'),
    ];

    return steps
        .map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildStepItem(context, step: step.$1, title: step.$2, description: step.$3),
            ))
        .toList();
  }

  /// 构建步骤项
  Widget _buildStepItem(BuildContext context, {required int step, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建二维码图片
  Widget _buildQRCodeImage(BuildContext context, double size) {
    if (_qrcodeBase64 == null) {
      return const Center(child: Icon(Icons.qr_code_2, size: 100, color: Colors.grey));
    }

    try {
      final image = _qrcodeBase64!.contains('base64,')
          ? Image.memory(
              base64Decode(_qrcodeBase64!.split('base64,')[1]),
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => _buildErrorWidget(context, '二维码加载失败'),
            )
          : Image.network(
              _qrcodeBase64!,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => _buildErrorWidget(context, '二维码加载失败'),
            );
      return image;
    } catch (e) {
      return _buildErrorWidget(context, '二维码解析失败');
    }
  }

  /// 构建错误提示组件
  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: _spacingSmall),
          Text(message, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error)),
        ],
      ),
    );
  }

  /// 构建二维码卡片
  Widget _buildQRCodeCard(BuildContext context) {
    if (_isLoadingQrcode) {
      return SettingCard(
        padding: const EdgeInsets.all(20),
        child: const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
      );
    }

    if (_secretKey == null || _qrcodeBase64 == null) {
      return SettingCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: _spacingLarge),
            Text('加载二维码失败', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: _spacingLarge),
            OutlinedButton(onPressed: _loadQrcode, child: const Text('重试')),
          ],
        ),
      );
    }
    
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, _) {
                final qrCodeSize = ((MediaQuery.of(context).size.width - 80) * 0.5).clamp(200.0, 240.0);
                
                return Container(
                  width: qrCodeSize,
                  height: qrCodeSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildQRCodeImage(context, qrCodeSize),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: _spacingLarge),
          _buildSecretKeyRow(context),
          const SizedBox(height: _spacingSmall),
          Text(
            '如果无法扫描二维码，请手动输入上方密钥',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建密钥显示行
  Widget _buildSecretKeyRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: _spacingMedium, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                _secretKey!,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(width: _spacingSmall),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.copy, size: 20, color: colorScheme.primary),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _secretKey!));
              MessageService.snackBar('密钥已复制');
            },
            tooltip: '复制密钥',
          ),
        ),
      ],
    );
  }

  /// 构建验证码输入框
  Widget _buildVerificationCodeInput(BuildContext context) {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Padding(
        padding: const EdgeInsets.only(top: _spacingSmall),
        child: TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: _getCodeInputDecoration(),
          style: _codeTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 构建身份验证器App卡片
  Widget _buildAuthenticatorAppCard(BuildContext context, String addedDate) {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.security, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: _spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('身份验证器App', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('添加于: $addedDate', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: _spacingSmall, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('已启用', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮组
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(text: '重置身份验证器', onPressed: () => _handleReset(context), isOutlined: true),
        const SizedBox(height: _spacingMedium),
        _buildActionButton(
          text: '删除身份验证器',
          onPressed: () => _handleDelete(context),
          isOutlined: true,
          isDanger: true,
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
    bool isDanger = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final button = isOutlined
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: isDanger ? Colors.red.shade600 : colorScheme.primary,
              side: BorderSide(
                color: isDanger ? Colors.red.shade400 : colorScheme.primary.withOpacity(0.5),
                width: 1.5,
              ),
              backgroundColor: isDanger 
                  ? Colors.red.shade50.withOpacity(0.1)
                  : colorScheme.primaryContainer.withOpacity(0.1),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : onPressed,
            child: _buildButtonChild(text, isDanger: isDanger),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 2,
              shadowColor: colorScheme.primary.withOpacity(0.3),
            ),
            onPressed: _isLoading ? null : onPressed,
            child: _buildButtonChild(text),
          );

    return SizedBox(width: double.infinity, child: button);
  }

  /// 构建按钮子组件
  Widget _buildButtonChild(String text, {bool isDanger = false}) {
    if (_isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDanger ? Colors.red.shade600 : Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// 构建安全提示
  Widget _buildSecurityTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '安全提示',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  '为保障您的加密货币资金安全,我们强烈建议您在适用的情况下禁用身份验证器的云同步功能。',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 处理设置操作
  Future<void> _handleSetup(BuildContext context) async {
    final code = _codeController.text.trim();
    
    if (code.isEmpty || code.length != 6) {
      MessageService.error('请输入6位验证码');
      return;
    }

    if (_secretKey == null) {
      MessageService.error('密钥未加载，请刷新页面重试');
      return;
    }

    MessageService.confirm(
      title: '确认设置',
      message: '确定要启用身份验证器App吗？',
      onConfirm: () async {
        await _performAction(
          action: () => _userRepository.bindGoogle2fa(secret: _secretKey!, code: code),
          onSuccess: () {
            MessageService.success('身份验证器App设置成功');
            _codeController.clear();
          },
          refreshUser: true,
        );
      },
    );
  }

  /// 处理重置操作
  Future<void> _handleReset(BuildContext context) async {
    MessageService.confirm(
      title: '确认重置',
      message: '重置身份验证器后，您需要使用新的二维码重新设置。确定要继续吗？',
      confirmText: '重置',
      onConfirm: () async {
        final code = await _showVerificationCodeDialog(context);
        if (code == null || code.isEmpty) return;

        await _performAction(
          action: () => _userRepository.unbindGoogle2fa(code: code),
          onSuccess: () {
            MessageService.success('身份验证器已重置，请重新设置');
            _loadQrcode();
          },
          refreshUser: true,
        );
      },
    );
  }

  /// 处理删除操作
  Future<void> _handleDelete(BuildContext context) async {
    MessageService.confirm(
      title: '确认删除',
      message: '删除身份验证器后，您的账户安全性将降低。确定要删除吗？',
      confirmText: '删除',
      confirmColor: Colors.red,
      onConfirm: () async {
        final code = await _showVerificationCodeDialog(context);
        if (code == null || code.isEmpty) return;

        await _performAction(
          action: () => _userRepository.unbindGoogle2fa(code: code),
          onSuccess: () => MessageService.success('身份验证器已删除'),
          refreshUser: true,
        );
      },
    );
  }

  /// 执行操作的通用方法
  Future<void> _performAction({
    required Future<void> Function() action,
    required VoidCallback onSuccess,
    bool refreshUser = false,
  }) async {
    setState(() => _isLoading = true);

    try {
      await action();
      if (refreshUser) {
        // 刷新用户信息，Observer 会自动响应状态变化
        await _userStore.getUserInfo();
        // 清空二维码相关数据，因为已设置后不再需要显示
        if (mounted) {
          setState(() {
            _secretKey = null;
            _qrcodeBase64 = null;
            _isLoadingQrcode = false;
          });
        }
      }
      if (mounted) onSuccess();
    } catch (e) {
      if (mounted) MessageService.error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 显示验证码输入对话框
  Future<String?> _showVerificationCodeDialog(BuildContext context) async {
    final codeController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20.0,
                offset: const Offset(0, 8.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '输入验证码',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _getCodeInputDecoration(),
                style: _codeTextStyle,
                textAlign: TextAlign.center,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      final code = codeController.text.trim();
                      if (code.length == 6) {
                        Navigator.of(dialogContext).pop(code);
                      } else {
                        MessageService.error('请输入6位验证码');
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      '确定',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
