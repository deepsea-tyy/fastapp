import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/data/network/apis/attachment/attachment_api.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/presentation/views/common/image_picker_sheet.dart';
import 'package:fastapp/presentation/views/feed/feed_notify_settings.dart';
import 'package:fastapp/presentation/views/common/modern_settings_tile.dart';
import 'package:fastapp/presentation/views/common/modern_switch.dart';

/// 个人资料设置页面
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final UserStore _userStore = getIt<UserStore>();
  final AttachmentApi _attachmentApi = getIt<AttachmentApi>();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isUploadingAvatar = false;
  String _nickname = '';
  String _username = '';
  String _avatar = '';
  String _signed = '';
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// 加载用户资料
  void _loadUserProfile() {
    final currentUser = _userStore.currentUser;
    if (currentUser == null) {
      if (mounted) {
        MessageService.error('请先登录');
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      _nickname = currentUser.profile?.nickname ?? '';
      _username = currentUser.username ?? 'Square-Creator-${currentUser.id.toRadixString(16)}';
      _avatar = currentUser.profile?.avatar ?? '';
      _signed = currentUser.profile?.signed ?? '';
      // Note: 本地 User 实体没有 isVerified 字段，默认为 false
      _isVerified = false;
      _isLoading = false;
    });
  }

  /// 选择并上传头像
  Future<void> _pickAndUploadAvatar() async {
    try {
      // 使用公共组件显示选择来源对话框
      final ImageSource? source = await ImagePickerSheet.show(context);
      if (source == null) return;

      // 选择图片
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      try {
        // 上传图片
        final uploadResult = await _attachmentApi.upload(
          filePath: pickedFile.path,
          fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        // 获取上传后的URL
        final uploadedUrl = uploadResult['url'] ?? uploadResult['path'];
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          throw Exception('上传失败：未获取到图片URL');
        }

        // 更新头像
        await _userStore.updateAvatar(uploadedUrl);

        // 更新本地显示
        setState(() {
          _avatar = uploadedUrl;
        });
      } catch (e) {
        if (mounted) {
          MessageService.error('上传失败: ${e.toString()}');
        }
        debugPrint('上传头像失败: $e');
      } finally {
        setState(() => _isUploadingAvatar = false);
      }
    } catch (e) {
      debugPrint('选择图片失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '编辑资料',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 24),
                _buildAvatarSection(),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(),
                const SizedBox(height: 16),
                _buildAccountSection(),
                const SizedBox(height: 16),
                _buildVerificationSection(),
                const SizedBox(height: 16),
                _buildNotificationSection(),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  /// 头像区域
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          // 头像
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarContent(),
              ),
            ),
          ),
          // 上传中遮罩
          if (_isUploadingAvatar)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          // 相机图标 - 统一样式
          if (!_isUploadingAvatar)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 头像内容
  Widget _buildAvatarContent() {
    if (_avatar.isEmpty || !ImageUtils.isValidImagePath(_avatar)) {
      return Center(
        child: Text(
          _nickname.isNotEmpty ? _nickname[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Image.network(
      ImageUtils.formatSingleImagePath(_avatar),
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            _nickname.isNotEmpty ? _nickname[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  /// 个人信息区域
  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernSectionHeader(
          title: '个人信息',
        ),
        ModernSettingsGroup(
          children: [
            ModernSettingsTile(
              icon: Icons.person_outline,
              label: '昵称',
              value: _nickname.isNotEmpty ? _nickname : '未设置',
              onTap: () => _editNickname(),
            ),
            ModernSettingsTile(
              icon: Icons.edit_note,
              label: '简介',
              value: _signed.isNotEmpty ? _signed : '未设置',
              onTap: () => _editSigned(),
            ),
          ],
        ),
      ],
    );
  }

  /// 账号信息区域
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernSectionHeader(
          title: '账号信息',
        ),
        ModernSettingsGroup(
          children: [
            ModernSettingsTile(
              icon: Icons.alternate_email,
              label: '用户名',
              value: _username,
              onTap: () => _editUsername(),
            ),
          ],
        ),
      ],
    );
  }

  /// 认证区域
  Widget _buildVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernSectionHeader(
          title: '账号认证',
        ),
        ModernSettingsGroup(
          children: [
            ModernSettingsTile(
              icon: Icons.verified_outlined,
              label: '认证创作者',
              value: '',
              trailing: _isVerified
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '已认证',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_border,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '立即申请',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
              onTap: () {
                if (_isVerified) {
                  MessageService.info('您已经是认证创作者');
                } else {
                  MessageService.warning('认证创作者功能开发中');
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 消息设置区域
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernSectionHeader(
          title: '其他设置',
        ),
        ModernSettingsGroup(
          children: [
            ModernSettingsTile(
              icon: Icons.notifications_outlined,
              label: '消息设置',
              value: '',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FeedNotifySettings(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 编辑昵称
  Future<void> _editNickname() async {
    final result = await MessageService.inputDialog(
      title: '编辑昵称',
      fields: [
        InputField(
          label: '昵称',
          hintText: '请输入昵称',
          initialValue: _nickname,
          maxLength: 20,
          autofocus: true,
          validator: (value) {
            if (value.isEmpty) {
              MessageService.warning('昵称不能为空');
              return false;
            }
            return true;
          },
        ),
      ],
      confirmText: '确定',
      cancelText: '取消',
    );

    if (result != null) {
      final newNickname = result['昵称'] ?? '';
      if (newNickname.isNotEmpty && newNickname != _nickname) {
        try {
          await _userStore.updateNickname(newNickname);
          setState(() {
            _nickname = newNickname;
          });
        } catch (e) {
          if (mounted) {
            MessageService.error('更新失败: ${e.toString()}');
          }
        }
      }
    }
  }

  /// 编辑签名
  Future<void> _editSigned() async {
    final result = await MessageService.inputDialog(
      title: '编辑简介',
      fields: [
        InputField(
          label: '简介',
          hintText: '请输入简介',
          initialValue: _signed,
          maxLength: 100,
          autofocus: true,
          keyboardType: TextInputType.multiline,
        ),
      ],
      confirmText: '确定',
      cancelText: '取消',
    );

    if (result != null) {
      final newSigned = result['简介'] ?? '';
      if (newSigned != _signed) {
        try {
          await _userStore.updateSigned(newSigned);
          setState(() {
            _signed = newSigned;
          });
        } catch (e) {
          if (mounted) {
            MessageService.error('更新失败: ${e.toString()}');
          }
        }
      }
    }
  }

  /// 编辑用户名
  Future<void> _editUsername() async {
    final result = await MessageService.inputDialog(
      title: '编辑用户名',
      fields: [
        InputField(
          label: '用户名',
          hintText: '请输入用户名',
          initialValue: _username,
          maxLength: 20,
          autofocus: true,
          validator: (value) {
            if (value.isEmpty) {
              MessageService.warning('用户名不能为空');
              return false;
            }
            // 用户名只能包含字母、数字、下划线和连字符
            if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
              MessageService.warning('用户名只能包含字母、数字、下划线和连字符');
              return false;
            }
            return true;
          },
        ),
      ],
      confirmText: '确定',
      cancelText: '取消',
    );

    if (result != null) {
      final newUsername = result['用户名'] ?? '';
      if (newUsername.isNotEmpty && newUsername != _username) {
        try {
          await _userStore.updateUsername(newUsername);
          setState(() {
            _username = newUsername;
          });
        } catch (e) {
          if (mounted) {
            MessageService.error('更新失败: ${e.toString()}');
          }
        }
      }
    }
  }
}
