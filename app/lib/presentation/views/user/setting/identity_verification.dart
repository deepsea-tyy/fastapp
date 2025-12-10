import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets.dart';

/// 认证中心页面
class IdentityVerificationScreen extends StatelessWidget {
  const IdentityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SettingAppBar(title: '认证中心', showCloseButton: true),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户信息区域
                    _buildUserInfoSection(context),
                    const SizedBox(height: 16),
                    // 升级认证区域
                    _buildUpgradeSection(context),
                    const SizedBox(height: 16),
                    // 账户限额区域
                    _buildAccountLimitsSection(context),
                    const SizedBox(height: 16),
                    // 个人信息区域
                    _buildPersonalInfoSection(context),
                    const SizedBox(height: 16),
                    // 重要提示
                    _buildImportantNotice(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfoSection(BuildContext context) {
    final userStore = getIt<UserStore>();

    return Observer(
      builder: (_) {
        final user = userStore.currentUser;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final userNo = user.no?.toString() ?? user.id.toString();
        final userId = 'User-$userNo';
        final numericId = 'ID: ${user.id}';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // 头像
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: user.profile?.avatar != null &&
                            user.profile!.avatar!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.profile!.avatar!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                  ),
                  // 徽章
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_florist,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // User ID
              Text(
                userId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // 数字ID
              Text(
                numericId,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              // 认证状态标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '标准身份认证',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建升级认证区域
  Widget _buildUpgradeSection(BuildContext context) {
    return SettingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '升级认证等级，将您的法币限额提升至2M USD 每日。',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '此项必填：',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '· 地址证明',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 跳转到开通进阶身份认证页面
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '开通进阶身份认证',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账户限额区域
  Widget _buildAccountLimitsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '账户限额',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLimitItem(
            context,
            '法币充提限额',
            '50K USD 每日',
          ),
          _buildLimitItem(
            context,
            '加密货币充值限额',
            '无限额',
          ),
          _buildLimitItem(
            context,
            '加密货币提现限额',
            '8M USDT 每日',
          ),
          _buildLimitItem(
            context,
            'C2C 交易限额',
            '无限额',
          ),
        ],
      ),
    );
  }

  /// 构建限额项
  Widget _buildLimitItem(BuildContext context, String label, String value) {
    return InfoRow(label: label, value: value);
  }

  /// 构建个人信息区域
  Widget _buildPersonalInfoSection(BuildContext context) {
    final userStore = getIt<UserStore>();

    return Observer(
      builder: (_) {
        final user = userStore.currentUser;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '个人信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 跳转到更新身份信息页面
                    },
                    child: const Text(
                      '更新身份信息',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPersonalInfoItem(
                context,
                '居住国',
                'Hong Kong(香港)',
                showChange: true,
              ),
              _buildPersonalInfoItem(
                context,
                '法定姓名',
                '沈海',
              ),
              _buildPersonalInfoItem(
                context,
                '出生日期',
                '1989-11-20',
              ),
              _buildPersonalInfoItem(
                context,
                '身份证件',
                '身份证 51**********1X',
              ),
              _buildPersonalInfoItem(
                context,
                '地址',
                '成都, Hong Kong(香港)',
              ),
              _buildPersonalInfoItem(
                context,
                '邮箱地址',
                'ty***@gmail.com',
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建个人信息项
  Widget _buildPersonalInfoItem(
    BuildContext context,
    String label,
    String value, {
    bool showChange = false,
  }) {
    return InfoRow(
      label: label,
      value: value,
      trailing: showChange
          ? TextButton(
              onPressed: () {
                // TODO: 更改居住国
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '更改',
                style: TextStyle(fontSize: 14),
              ),
            )
          : null,
    );
  }

  /// 构建重要提示
  Widget _buildImportantNotice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.amber[300],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '①',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '如需更新或更正法定姓名或出生日期，请通过我们的姓名更正申诉或出生日期更正申诉流程提交请求。',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
