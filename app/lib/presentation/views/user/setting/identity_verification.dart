import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/store/kyc/ex_kyc_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets.dart';
import 'kyc_submit_screen.dart';

/// 认证中心页面
class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  final _userStore = getIt<UserStore>();
  final _kycStore = getIt<ExKycStore>();

  @override
  void initState() {
    super.initState();
    // 加载KYC数据
    _loadKycData();
  }

  Future<void> _loadKycData() async {
    try {
      await _kycStore.fetchAllKycDetails();
    } catch (e) {
      // 错误已由 ErrorStore 处理
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SettingAppBar(title: '认证中心', showCloseButton: true),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_kycStore.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: _loadKycData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfoSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final user = _userStore.currentUser;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final userNo = user.no?.toString() ?? user.id.toString();
        final userId = 'User-$userNo';
        final numericId = 'ID: ${user.id}';

        // 获取当前KYC状态
        final level1Kyc = _kycStore.level1Kyc;
        final isLevel1Approved = level1Kyc?.isApproved ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧：头像
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: user.profile?.avatar != null &&
                            user.profile!.avatar!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.profile!.avatar!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.grey[600],
                          ),
                  ),
                  // 徽章
                  if (isLevel1Approved)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // 右侧：用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 认证状态标签
                    if (level1Kyc != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(level1Kyc.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(level1Kyc.status),
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              level1Kyc.kycLevelText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '未认证',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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

  /// 获取状态颜色
  Color _getStatusColor(int status) {
    switch (status) {
      case 0: // 待审核
      case 1: // 审核中
        return Colors.orange[600]!;
      case 2: // 已通过
        return Colors.green[400]!;
      case 3: // 已拒绝
        return Colors.red[400]!;
      case 4: // 已取消
        return Colors.grey[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0: // 待审核
      case 1: // 审核中
        return Icons.schedule;
      case 2: // 已通过
        return Icons.check_circle;
      case 3: // 已拒绝
        return Icons.cancel;
      case 4: // 已取消
        return Icons.remove_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  /// 构建升级认证区域
  Widget _buildUpgradeSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final level1Kyc = _kycStore.level1Kyc;
        final level2Kyc = _kycStore.level2Kyc;
        final isLevel1Approved = level1Kyc?.isApproved ?? false;
        final isLevel2Approved = level2Kyc?.isApproved ?? false;
        final isLevel2Pending = level2Kyc?.isPending ?? false;

        // 如果已完成进阶认证，不显示升级区域
        if (isLevel2Approved) {
          return const SizedBox.shrink();
        }

        return SettingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLevel1Approved
                    ? '升级认证等级，将您的法币限额提升至2M USD 每日。'
                    : '完成身份认证，解锁更多功能和更高的交易限额。',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!isLevel1Approved && level1Kyc == null) ...[
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text(
                      '此项必填：',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '· 身份证件 · 个人信息',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              if (isLevel1Approved && !isLevel2Approved) ...[
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text(
                      '此项必填：',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '· 地址证明',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLevel2Pending
                      ? null
                      : () {
                          final targetLevel = isLevel1Approved ? 2 : 1;
                          _showKycInfoDialog(context, targetLevel);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLevel2Pending
                        ? Colors.grey[400]
                        : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isLevel2Pending
                        ? '进阶认证审核中'
                        : isLevel1Approved
                            ? '开通进阶身份认证'
                            : '开通标准身份认证',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 显示KYC认证信息弹框
  void _showKycInfoDialog(BuildContext context, int kycLevel) {
    final isLevel1 = kycLevel == 1;
    final title = isLevel1 ? '标准身份认证' : '进阶身份认证';
    final description = isLevel1
        ? '完成标准身份认证后，您将获得：\n\n• 法币充提限额提升至 50K USD/日\n• 加密货币提现限额 8M USDT/日\n• 解锁更多交易功能'
        : '完成进阶身份认证后，您将获得：\n\n• 法币充提限额提升至 2M USD/日\n• 加密货币提现限额 10M USDT/日\n• 更高的账户安全等级';
    final requiredDocs = isLevel1
        ? '• 有效身份证件（身份证/护照/驾驶证）\n• 个人基本信息\n• 手持证件自拍照'
        : '• 地址证明文件（水电费账单/银行对账单）\n• GPS定位信息';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '所需材料：',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                requiredDocs,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '请确保提供的信息真实有效，审核通过后将无法修改。',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 跳转到KYC认证表单页面
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => KycSubmitScreen(kycLevel: kycLevel),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '开始认证',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账户限额区域
  Widget _buildAccountLimitsSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final maxLevel = _kycStore.maxApprovedLevel;

        // 根据认证等级显示不同的限额
        String fiatLimit = '0 USD 每日'; // 未认证
        String cryptoWithdrawLimit = '0 USDT 每日';

        if (maxLevel >= 2) {
          // 进阶认证
          fiatLimit = '2M USD 每日';
          cryptoWithdrawLimit = '10M USDT 每日';
        } else if (maxLevel >= 1) {
          // 标准认证
          fiatLimit = '50K USD 每日';
          cryptoWithdrawLimit = '8M USDT 每日';
        }

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
              _buildLimitItem(context, '法币充提限额', fiatLimit),
              _buildLimitItem(context, '加密货币充值限额', '无限额'),
              _buildLimitItem(context, '加密货币提现限额', cryptoWithdrawLimit),
              _buildLimitItem(context, 'C2C 交易限额', '无限额'),
            ],
          ),
        );
      },
    );
  }

  /// 构建限额项
  Widget _buildLimitItem(BuildContext context, String label, String value) {
    return InfoRow(label: label, value: value);
  }

  /// 构建个人信息区域
  Widget _buildPersonalInfoSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final user = _userStore.currentUser;
        final kyc = _kycStore.currentKyc;

        if (user == null || kyc == null) {
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
                  if (kyc.isRejected)
                    TextButton(
                      onPressed: () {
                        _showKycInfoDialog(context, kyc.kycLevel);
                      },
                      child: const Text(
                        '更新身份信息',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (kyc.countryCode != null)
                _buildPersonalInfoItem(
                  context,
                  '居住国',
                  kyc.countryCode!,
                ),
              if (kyc.fullName.isNotEmpty)
                _buildPersonalInfoItem(
                  context,
                  '法定姓名',
                  kyc.fullName,
                ),
              if (kyc.birthday != null)
                _buildPersonalInfoItem(
                  context,
                  '出生日期',
                  kyc.birthday!,
                ),
              if (kyc.idType != null && kyc.idNumber != null)
                _buildPersonalInfoItem(
                  context,
                  '身份证件',
                  '${kyc.idTypeText} ${kyc.maskedIdNumber}',
                ),
              if (kyc.address != null)
                _buildPersonalInfoItem(
                  context,
                  '地址',
                  kyc.address!,
                ),
              if (user.email != null)
                _buildPersonalInfoItem(
                  context,
                  '邮箱地址',
                  user.email!,
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
