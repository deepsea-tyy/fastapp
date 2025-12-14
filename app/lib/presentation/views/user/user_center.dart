import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/domain/entity/user/user.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastapp/presentation/views/user/setting/widgets.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/data/network/apis/attachment/attachment_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fastapp/utils/image_utils.dart';

/// 用户中心页面
class UserCenterScreen extends StatefulWidget {
  const UserCenterScreen({super.key});

  @override
  State<UserCenterScreen> createState() => _UserCenterScreenState();
}

class _UserCenterScreenState extends State<UserCenterScreen> {
  // 常量配置
  static const _cardMargin = EdgeInsets.all(16.0);
  static const _cardPadding = EdgeInsets.all(16.0);
  static const _avatarSize = 50.0;
  static const _iconSize = 20.0;

  // 是否显示完整的手机号
  bool _showMobile = false;
  
  // VIP等级信息
  int? _vipLevel;
  Map<String, dynamic>? _vipData;
  bool _isLoadingVip = false;

  @override
  void initState() {
    super.initState();
    _loadVipInfo();
  }

  /// 加载VIP信息
  Future<void> _loadVipInfo() async {
    if (_isLoadingVip) return;

    setState(() {
      _isLoadingVip = true;
    });

    try {
      final userApi = getIt<UserApi>();
      final response = await userApi.getVipDetail();

      if (mounted) {
        setState(() {
          _vipLevel = response['level'] as int? ?? 0;
          _vipData = response;
        });
      }
    } catch (e) {
      // 静默失败，不影响页面显示
      if (mounted) {
        setState(() {
          _vipLevel = 0; // 默认普通用户
          _vipData = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVip = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SettingAppBar(title: '用户中心'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUserProfileCard(context),
                    _buildFeatureList(context),
                  ],
                ),
              ),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  /// 构建用户资料卡片
  Widget _buildUserProfileCard(BuildContext context) {
    final userStore = getIt<UserStore>();
    
    return Observer(
      builder: (_) {
        final user = userStore.currentUser;
        if (user == null) {
          return Container(
            margin: _cardMargin,
            padding: _cardPadding,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        final theme = Theme.of(context);
        final displayName = _getDisplayName(user);
        final userNo = user.no?.toString() ?? user.id.toString();
        
        return Container(
          margin: _cardMargin,
          padding: _cardPadding,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // 头像 - 点击可编辑
                  GestureDetector(
                    onTap: () => _showEditAvatarDialog(context, userStore),
                    child: _buildAvatar(user.profile?.avatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: _iconSize),
                    onPressed: () {
                      _showEditNicknameDialog(context, userStore, user);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'ID',
                userNo,
                Icons.copy,
                onIconTap: () {
                  Clipboard.setData(ClipboardData(text: userNo));
                  MessageService.snackBar('ID已复制');
                },
              ),
              if (user.mobile?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  '注册信息',
                  _showMobile ? user.mobile! : _maskMobile(user.mobile!),
                  _showMobile ? Icons.visibility_off : Icons.visibility,
                  onIconTap: () {
                    setState(() {
                      _showMobile = !_showMobile;
                    });
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 获取显示名称
  String _getDisplayName(User user) {
    if (user.profile?.nickname?.isNotEmpty == true) {
      return user.profile!.nickname!;
    }
    if (user.username?.isNotEmpty == true) {
      return user.username!;
    }
    return user.mobile ?? user.email ?? '未设置';
  }

  /// 隐藏手机号中间部分
  String _maskMobile(String mobile) {
    if (mobile.length <= 7) {
      return mobile;
    }
    // 显示前3位和后4位，中间用*代替
    final prefix = mobile.substring(0, 3);
    final suffix = mobile.substring(mobile.length - 4);
    final middle = '*' * (mobile.length - 7);
    return '$prefix$middle$suffix';
  }
  
  /// 构建头像
  Widget _buildAvatar(String? avatarUrl) {
    final defaultAvatar = Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
    );

    if (avatarUrl?.isNotEmpty != true) return defaultAvatar;

    // 使用 ImageUtils 处理头像 URL
    final imageUrl = ImageUtils.formatImagePath(avatarUrl);

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: _avatarSize,
        height: _avatarSize,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: _avatarSize,
          height: _avatarSize,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => defaultAvatar,
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    required VoidCallback onIconTap,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
        ),
        IconButton(
          icon: Icon(icon, size: 18),
          onPressed: onIconTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  /// 构建功能列表
  Widget _buildFeatureList(BuildContext context) {
    final userStore = getIt<UserStore>();

    return Observer(
      builder: (_) {
        final isKyc = userStore.currentUser?.isKyc;
        final theme = Theme.of(context);

        // 获取VIP显示文本和颜色
        final vipText = _getVipText(_vipLevel);
        final vipColor = _getVipColor(_vipLevel);

        // 获取KYC显示文本和颜色
        final kycText = _getKycStatusText(isKyc);
        final kycColor = _getKycStatusColor(isKyc);

        return Column(
          children: [
            _buildFeatureItem(
              context,
              icon: Icons.diamond,
              title: 'VIP特权',
              trailing: _isLoadingVip
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _buildStatusTag(vipText, vipColor),
              onTap: () {
                Navigator.of(context).pushNamed(
                  Routes.vipPrivilege,
                  arguments: _vipData,
                ).then((_) {
                  // 从VIP特权页面返回时刷新VIP信息
                  _loadVipInfo();
                });
              },
            ),
            _buildFeatureItem(
              context,
              icon: Icons.person,
              title: '身份认证',
              trailing: _buildStatusTag(kycText, kycColor),
              onTap: () => _navigateToIdentityVerification(context, userStore),
            ),
            _buildFeatureItem(
              context,
              icon: Icons.lock,
              title: '安全设置',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(Routes.accountSecurity),
            ),
          ],
        );
      },
    );
  }

  /// 导航到身份认证页面
  Future<void> _navigateToIdentityVerification(BuildContext context, UserStore userStore) async {
    await Navigator.of(context).pushNamed(Routes.identityVerification);
    if (context.mounted) {
      await userStore.getUserInfo();
    }
  }

  /// 构建功能项
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return SettingItem(
      title: title,
      leadingIcon: icon,
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 构建状态标签
  Widget _buildStatusTag(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusTag(text: text, color: color),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  /// 构建退出按钮
  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: _cardMargin,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleLogout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[800],
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: const Text(
            '退出登录',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// 处理退出登录
  void _handleLogout(BuildContext context) {
    MessageService.confirm(
      title: '确认退出',
      message: '确定要退出登录吗？',
      confirmText: '确定',
      cancelText: '取消',
      confirmColor: Colors.red,
      onConfirm: () async {
        final userStore = getIt<UserStore>();
        await userStore.logout();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.home,
            (route) => false,
          );
        }
      },
    );
  }

  /// 显示编辑昵称对话框
  Future<void> _showEditNicknameDialog(BuildContext context, UserStore userStore, User user) async {
    final result = await MessageService.inputDialog(
      title: '编辑昵称',
      fields: [
        InputField(
          label: '昵称',
          hintText: '请输入昵称',
          initialValue: user.profile?.nickname ?? '',
          maxLength: 60,
          autofocus: true,
          validator: (value) {
            if (value.isEmpty) {
              MessageService.snackBar('昵称不能为空');
              return false;
            }
            if (value.contains(' ')) {
              MessageService.snackBar('昵称不能包含空格');
              return false;
            }
            return true;
          },
        ),
      ],
    );

    if (result != null && result['昵称'] != null) {
      final nickname = result['昵称']!.trim();
      await _updateNickname(context, userStore, nickname);
    }
  }

  /// 更新昵称
  Future<void> _updateNickname(BuildContext context, UserStore userStore, String nickname) async {
    try {
      await userStore.updateNickname(nickname);
    } catch (e) {
      if (context.mounted) {
        MessageService.snackBar('更新失败: ${e.toString()}');
      }
    }
  }

  /// 显示编辑头像对话框
  Future<void> _showEditAvatarDialog(BuildContext context, UserStore userStore) async {
    final ImagePicker picker = ImagePicker();

    try {
      // 显示底部选择框：拍照或从相册选择
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('拍照'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // 根据用户选择的方式获取图片
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!context.mounted) return;

      // 显示上传进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在上传头像...'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      try {
        // 上传图片
        final attachmentApi = getIt<AttachmentApi>();
        final uploadResult = await attachmentApi.upload(
          filePath: image.path,
          fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          onSendProgress: (sent, total) {
            final progress = (sent / total * 100).toStringAsFixed(0);
            debugPrint('上传进度: $progress%');
          },
        );

        // 获取上传后的图片URL
        final avatarUrl = uploadResult['url'] as String?;

        if (avatarUrl == null || avatarUrl.isEmpty) {
          throw Exception('上传成功但未返回图片URL');
        }

        // 使用 ImageUtils 处理 URL，提取相对路径用于保存
        final processedUrl = ImageUtils.processUrl(avatarUrl);

        // 更新用户头像
        await userStore.updateAvatar(processedUrl);

        // 关闭加载对话框
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (context.mounted) {
          MessageService.snackBar('头像更新成功');
        }
      } catch (e) {
        // 关闭加载对话框
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (context.mounted) {
          String errorMessage = '更新头像失败';

          if (e.toString().contains('文件大小超过限制')) {
            errorMessage = e.toString().replaceAll('Exception: ', '');
          } else if (e.toString().contains('文件不存在')) {
            errorMessage = '图片文件不存在';
          } else {
            errorMessage = '更新头像失败: ${e.toString()}';
          }

          MessageService.snackBar(errorMessage);
        }
      }
    } catch (e) {
      if (context.mounted) {
        MessageService.snackBar('选择图片失败: ${e.toString()}');
      }
    }
  }

  /// 获取VIP显示文本
  String _getVipText(int? level) {
    if (level == null) {
      return '普通用户';
    }
    if (level == 0) {
      return '普通用户';
    }
    return 'VIP$level';
  }

  /// 获取VIP显示颜色
  Color _getVipColor(int? level) {
    if (level == null || level == 0) {
      return Colors.orange[300]!;
    }
    // VIP用户使用更鲜艳的颜色
    return Colors.purple[400]!;
  }

  /// 获取 KYC 状态显示文本
  /// 0: 未认证
  /// 1: 标准认证审核中
  /// 2: 标准认证完成
  /// 3: 标准认证未通过
  /// 4: 进阶认证审核中
  /// 5: 进阶认证完成
  /// 6: 进阶认证未通过
  String _getKycStatusText(int? isKyc) {
    switch (isKyc) {
      case 0:
        return '未认证';
      case 1:
        return '审核中';
      case 2:
        return '标准认证';
      case 3:
        return '未通过';
      case 4:
        return '审核中';
      case 5:
        return '进阶认证';
      case 6:
        return '未通过';
      default:
        return '未认证';
    }
  }

  /// 获取 KYC 状态颜色
  Color _getKycStatusColor(int? isKyc) {
    switch (isKyc) {
      case 0:
        return Colors.grey[400]!;
      case 1:
      case 4:
        return Colors.orange[300]!; // 审核中
      case 2:
        return Colors.green[300]!; // 标准认证完成
      case 5:
        return Colors.green[400]!; // 进阶认证完成（更深的绿色）
      case 3:
      case 6:
        return Colors.red[300]!; // 未通过
      default:
        return Colors.grey[400]!;
    }
  }
}
