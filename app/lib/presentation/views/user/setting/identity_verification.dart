import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/store/kyc/ex_kyc_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastapp/utils/image_utils.dart';
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
                          const SizedBox(height: 16),
                          // KYC 状态详情区域
                          _buildKycStatusSection(context),
                          const SizedBox(height: 16),
                          // 升级认证区域
                          _buildUpgradeSection(context),
                          const SizedBox(height: 16),
                          // 个人信息区域
                          _buildPersonalInfoSection(context),
                          // 已提交的证件图片
                          _buildSubmittedDocumentsSection(context),
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

  // ==================== KYC 状态辅助方法 ====================

  /// 获取 KYC 状态文本
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
        return '标准认证审核中';
      case 2:
        return '标准认证完成';
      case 3:
        return '标准认证未通过';
      case 4:
        return '进阶认证审核中';
      case 5:
        return '进阶认证完成';
      case 6:
        return '进阶认证未通过';
      default:
        return '未认证';
    }
  }

  /// 获取 KYC 状态颜色
  Color _getKycStatusColor(int? isKyc) {
    switch (isKyc) {
      case 0:
        return Colors.grey;
      case 1:
      case 4:
        return Colors.orange; // 审核中
      case 2:
      case 5:
        return Colors.green; // 已完成
      case 3:
      case 6:
        return Colors.red; // 未通过
      default:
        return Colors.grey;
    }
  }

  /// 获取 KYC 状态图标
  IconData _getKycStatusIcon(int? isKyc) {
    switch (isKyc) {
      case 0:
        return Icons.info_outline;
      case 1:
      case 4:
        return Icons.pending; // 审核中
      case 2:
      case 5:
        return Icons.verified; // 已完成
      case 3:
      case 6:
        return Icons.cancel; // 未通过
      default:
        return Icons.info_outline;
    }
  }

  /// 判断是否已完成标准认证
  bool _isLevel1Completed(int? isKyc) {
    return isKyc != null && isKyc >= 2;
  }

  /// 判断是否已完成进阶认证
  bool _isLevel2Completed(int? isKyc) {
    return isKyc == 5;
  }

  /// 判断是否可以升级到进阶认证
  bool _canUpgradeToLevel2(int? isKyc) {
    return isKyc == 2; // 标准认证完成
  }

  /// 判断是否可以重新提交标准认证
  bool _canResubmitLevel1(int? isKyc) {
    return isKyc == 0 || isKyc == 3; // 未认证或标准认证未通过
  }

  /// 判断是否可以重新提交进阶认证
  bool _canResubmitLevel2(int? isKyc) {
    return isKyc == 6; // 进阶认证未通过
  }

  /// 判断标准认证是否在审核中
  bool _isLevel1Pending(int? isKyc) {
    return isKyc == 1;
  }

  /// 判断进阶认证是否在审核中
  bool _isLevel2Pending(int? isKyc) {
    return isKyc == 4;
  }

  // ==================== UI 构建方法 ====================

  /// 构建 KYC 状态详情区域
  Widget _buildKycStatusSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final user = _userStore.currentUser;
        final isKyc = user?.isKyc;

        // 如果未认证，不显示状态卡片
        if (isKyc == null || isKyc == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getKycStatusColor(isKyc).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  children: [
                    Icon(_getKycStatusIcon(isKyc), color: _getKycStatusColor(isKyc), size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isLevel2Completed(isKyc) || _isLevel2Pending(isKyc) || _canResubmitLevel2(isKyc)
                            ? '进阶认证 (Level 2)'
                            : '标准认证 (Level 1)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getKycStatusColor(isKyc),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getKycStatusText(isKyc),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // 根据状态显示不同的提示信息
                _buildStatusMessage(isKyc),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建状态提示信息
  Widget _buildStatusMessage(int isKyc) {
    if (_isLevel1Pending(isKyc) || _isLevel2Pending(isKyc)) {
      // 审核中
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.schedule, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '您的认证申请正在审核中，通常需要 1-3 个工作日，请耐心等待。',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_isLevel1Completed(isKyc) && !_isLevel2Completed(isKyc)) {
      // 标准认证完成
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '恭喜！您的标准认证已通过，现在可以升级到进阶认证以享受更高的交易限额。',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_isLevel2Completed(isKyc)) {
      // 进阶认证完成
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '恭喜！您已完成最高级别的身份认证，现在可以享受最高的交易限额和全部功能。',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_canResubmitLevel1(isKyc) || _canResubmitLevel2(isKyc)) {
      // 认证未通过
      // 获取当前等级的 KYC 记录以获取拒绝原因
      final kyc = _canResubmitLevel2(isKyc) ? _kycStore.level2Kyc : _kycStore.level1Kyc;
      final hasRemark = kyc?.remark != null && kyc!.remark!.isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '您的认证申请被拒绝，请检查提交的信息是否准确，然后重新提交。',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (hasRemark) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '拒绝原因：',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kyc!.remark!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 构建升级认证区域
  Widget _buildUpgradeSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final user = _userStore.currentUser;
        final isKyc = user?.isKyc;

        // 如果已完成进阶认证，不显示升级区域
        if (_isLevel2Completed(isKyc)) {
          return const SizedBox.shrink();
        }

        // 确定目标等级和按钮状态
        int targetLevel;
        String buttonText;
        bool isButtonDisabled;
        String description;
        String? requiredItems;

        if (_canResubmitLevel1(isKyc)) {
          // 未认证或标准认证未通过 -> 可以提交/重新提交标准认证
          targetLevel = 1;
          buttonText = isKyc == 3 ? '重新提交标准认证' : '开通标准身份认证';
          isButtonDisabled = false;
          description = '完成身份认证，解锁更多功能和更高的交易限额。';
          requiredItems = '· 身份证件 · 个人信息';
        } else if (_isLevel1Pending(isKyc)) {
          // 标准认证审核中 -> 按钮禁用
          targetLevel = 1;
          buttonText = '标准认证审核中';
          isButtonDisabled = true;
          description = '您的标准认证正在审核中，请耐心等待审核结果。';
          requiredItems = null;
        } else if (_canUpgradeToLevel2(isKyc)) {
          // 标准认证完成 -> 可以升级到进阶认证
          targetLevel = 2;
          buttonText = '开通进阶身份认证';
          isButtonDisabled = false;
          description = '升级认证等级，将您的法币限额提升至2M USD 每日。';
          requiredItems = '· 地址证明 · GPS定位';
        } else if (_canResubmitLevel2(isKyc)) {
          // 进阶认证未通过 -> 可以重新提交进阶认证
          targetLevel = 2;
          buttonText = '重新提交进阶认证';
          isButtonDisabled = false;
          description = '您的进阶认证未通过，请检查并重新提交。';
          requiredItems = '· 地址证明 · GPS定位';
        } else if (_isLevel2Pending(isKyc)) {
          // 进阶认证审核中 -> 按钮禁用
          targetLevel = 2;
          buttonText = '进阶认证审核中';
          isButtonDisabled = true;
          description = '您的进阶认证正在审核中，请耐心等待审核结果。';
          requiredItems = null;
        } else {
          // 其他情况（不应该出现）
          return const SizedBox.shrink();
        }

        return SettingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (requiredItems != null) ...[
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
                      requiredItems,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isButtonDisabled
                      ? null
                      : () async {
                          // 直接跳转到 KYC 认证表单页面
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => KycSubmitScreen(kycLevel: targetLevel),
                            ),
                          );
                          // 如果提交成功，刷新 KYC 数据
                          if (result == true && mounted) {
                            await _loadKycData();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonDisabled
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
                    buttonText,
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

  /// 构建个人信息区域
  Widget _buildPersonalInfoSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final user = _userStore.currentUser;
        final kyc = _kycStore.currentKyc;

        // 如果用户都没有，不显示
        if (user == null) {
          return const SizedBox.shrink();
        }

        // 如果没有 KYC 数据，只显示用户基本信息
        if (kyc == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '个人信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (user.email != null)
                  _buildPersonalInfoItem(
                    context,
                    '邮箱地址',
                    user.email!,
                  ),
                if (user.mobile != null)
                  _buildPersonalInfoItem(
                    context,
                    '手机号码',
                    user.mobile!,
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '完成身份认证后，您的个人信息将在此处显示。',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // 如果有 KYC 数据，显示完整信息
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
                  // 如果认证被拒绝，显示更新按钮
                  if (_canResubmitLevel1(user?.isKyc) || _canResubmitLevel2(user?.isKyc))
                    TextButton(
                      onPressed: () async {
                        // 确定目标等级
                        final targetLevel = _canResubmitLevel2(user?.isKyc) ? 2 : 1;
                        // 直接跳转到 KYC 认证表单页面
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => KycSubmitScreen(kycLevel: targetLevel),
                          ),
                        );
                        // 如果提交成功，刷新 KYC 数据
                        if (result == true && mounted) {
                          await _loadKycData();
                        }
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
              if (kyc.gender != null)
                _buildPersonalInfoItem(
                  context,
                  '性别',
                  kyc.genderText,
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
              if (kyc.idIssueDate != null)
                _buildPersonalInfoItem(
                  context,
                  '证件签发日期',
                  kyc.idIssueDate!,
                ),
              if (kyc.idExpiryDate != null)
                _buildPersonalInfoItem(
                  context,
                  '证件到期日期',
                  kyc.idExpiryDate!,
                ),
              if (kyc.address != null)
                _buildPersonalInfoItem(
                  context,
                  '地址',
                  kyc.address!,
                ),
              if (kyc.locationAddress != null)
                _buildPersonalInfoItem(
                  context,
                  'GPS定位地址',
                  kyc.locationAddress!,
                ),
              if (user.email != null)
                _buildPersonalInfoItem(
                  context,
                  '邮箱地址',
                  user.email!,
                ),
              if (user.mobile != null)
                _buildPersonalInfoItem(
                  context,
                  '手机号码',
                  user.mobile!,
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

  /// 构建已提交的证件图片区域
  Widget _buildSubmittedDocumentsSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final kyc = _kycStore.currentKyc;

        if (kyc == null) {
          return const SizedBox.shrink();
        }

        // 检查是否有任何图片
        final hasAnyImage = kyc.idFrontImage != null ||
            kyc.idBackImage != null ||
            kyc.idSelfieImage != null ||
            kyc.addressProofImage != null;

        if (!hasAnyImage) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                '已提交的证件',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // 身份证正面
              if (kyc.idFrontImage != null)
                _buildDocumentImageItem(
                  context,
                  '身份证件正面',
                  kyc.idFrontImage!,
                ),
              // 身份证反面
              if (kyc.idBackImage != null)
                _buildDocumentImageItem(
                  context,
                  '身份证件反面',
                  kyc.idBackImage!,
                ),
              // 手持证件自拍
              if (kyc.idSelfieImage != null)
                _buildDocumentImageItem(
                  context,
                  '手持证件自拍',
                  kyc.idSelfieImage!,
                ),
              // 地址证明（仅 Level 2）
              if (kyc.addressProofImage != null)
                _buildDocumentImageItem(
                  context,
                  '地址证明',
                  kyc.addressProofImage!,
                ),
            ],
          ),
        );
      },
    );
  }

  /// 构建单个证件图片项
  Widget _buildDocumentImageItem(
    BuildContext context,
    String label,
    String imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: ImageUtils.formatSingleImagePath(imageUrl),
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          '图片加载失败',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
