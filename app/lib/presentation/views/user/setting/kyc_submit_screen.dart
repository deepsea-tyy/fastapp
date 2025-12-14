import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/kyc/ex_kyc_store.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:fastapp/constants/country_data.dart';
import 'package:fastapp/data/network/apis/attachment/attachment_api.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'widgets.dart';
import '../../common/date_picker_bottom_sheet.dart';

/// KYC认证提交页面
class KycSubmitScreen extends StatefulWidget {
  final int kycLevel;

  const KycSubmitScreen({
    super.key,
    required this.kycLevel,
  });

  @override
  State<KycSubmitScreen> createState() => _KycSubmitScreenState();
}

class _KycSubmitScreenState extends State<KycSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kycStore = getIt<ExKycStore>();
  final _attachmentApi = getIt<AttachmentApi>();
  final _imagePicker = ImagePicker();

  // 表单控制器
  late final _surnameController = TextEditingController();
  late final _middleNameController = TextEditingController();
  late final _nameController = TextEditingController();
  late final _birthdayController = TextEditingController();
  late final _idNumberController = TextEditingController();
  late final _idIssueDateController = TextEditingController();
  late final _idExpiryDateController = TextEditingController();
  late final _addressController = TextEditingController();

  // 表单数据
  CountryData _selectedCountry = Countries.defaultCountry;
  int _selectedGender = 1;
  String _selectedIdType = 'ID_CARD';
  DateTime? _birthday;
  DateTime? _idIssueDate;
  DateTime? _idExpiryDate;

  // 图片路径
  String? _idFrontImage;
  String? _idBackImage;
  String? _idSelfieImage;
  String? _addressProofImage;

  // GPS定位信息
  double? _latitude;
  double? _longitude;
  double? _locationAccuracy;
  String? _locationAddress;
  DateTime? _locationTime;
  bool _isLoadingLocation = false;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 常量
  static const _dateFormat = 'yyyy-MM-dd';
  static const _dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const _photoSize = 60.0;
  static const _iconSize = 18.0;

  @override
  void initState() {
    super.initState();
    // 直接从 store 中读取已加载的数据，不重复请求
    _initializeData();
  }

  /// 初始化数据（直接使用已加载的数据）
  void _initializeData() {
    // Level 1: 如果有已提交的记录，预填充数据（无论状态）
    if (widget.kycLevel == 1) {
      final level1Kyc = _kycStore.level1Kyc;
      if (level1Kyc != null) {
        _loadKycData(level1Kyc);
      }
    }
    // Level 2: 优先从 Level 2 预填充基础数据，如果没有则从 Level 1 预填充
    else if (widget.kycLevel == 2) {
      final level2Kyc = _kycStore.level2Kyc;
      final level1Kyc = _kycStore.level1Kyc;

      // 如果有 Level 2 记录，优先使用 Level 2 的数据（重新提交场景）
      if (level2Kyc != null) {
        _loadKycData(level2Kyc);
        // Level 2 的额外字段
        _addressProofImage = level2Kyc.addressProofImage;
        _latitude = level2Kyc.latitude;
        _longitude = level2Kyc.longitude;
        _locationAccuracy = level2Kyc.locationAccuracy;
        _locationAddress = level2Kyc.locationAddress;
        if (level2Kyc.locationTime != null) {
          try {
            _locationTime = DateFormat(_dateTimeFormat).parse(level2Kyc.locationTime!);
          } catch (e) {
            // 解析失败，忽略
          }
        }
      }
      // 如果没有 Level 2 记录但有 Level 1 记录，从 Level 1 预填充基础数据（首次提交场景）
      else if (level1Kyc != null) {
        _loadKycData(level1Kyc);
      }
    }
  }

  /// 从 KYC 数据加载并预填充表单
  void _loadKycData(dynamic kyc) {
    if (kyc == null) return;

    // 预填充基本信息
    if (kyc.countryCode != null) {
      _selectedCountry = Countries.all.firstWhere(
        (c) => c.code == kyc.countryCode,
        orElse: () => Countries.defaultCountry,
      );
    }

    _surnameController.text = kyc.surname ?? '';
    _middleNameController.text = kyc.middleName ?? '';
    _nameController.text = kyc.name ?? '';
    _selectedGender = kyc.gender ?? 1;

    // 预填充日期
    _parseAndSetDate(kyc.birthday, (date) {
      _birthday = date;
      _birthdayController.text = DateFormat(_dateFormat).format(date);
    });

    // 预填充证件信息
    _selectedIdType = kyc.idType ?? 'ID_CARD';
    _idNumberController.text = kyc.idNumber ?? '';

    _parseAndSetDate(kyc.idIssueDate, (date) {
      _idIssueDate = date;
      _idIssueDateController.text = DateFormat(_dateFormat).format(date);
    });

    _parseAndSetDate(kyc.idExpiryDate, (date) {
      _idExpiryDate = date;
      _idExpiryDateController.text = DateFormat(_dateFormat).format(date);
    });

    // 预填充地址和证件图片
    _addressController.text = kyc.address ?? '';
    _idFrontImage = kyc.idFrontImage;
    _idBackImage = kyc.idBackImage;
    _idSelfieImage = kyc.idSelfieImage;
  }

  /// 解析日期字符串并设置（支持带时间和不带时间的格式）
  void _parseAndSetDate(String? dateString, Function(DateTime) onSuccess) {
    if (dateString == null) return;
    try {
      final date = dateString.contains(' ')
          ? DateFormat(_dateTimeFormat).parse(dateString)
          : DateFormat(_dateFormat).parse(dateString);
      onSuccess(date);
    } catch (e) {
      // 解析失败，忽略
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _surnameController.dispose();
    _middleNameController.dispose();
    _nameController.dispose();
    _birthdayController.dispose();
    _idNumberController.dispose();
    _idIssueDateController.dispose();
    _idExpiryDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SettingAppBar(
              title: widget.kycLevel == 1 ? '标准身份认证' : '进阶身份认证',
              showCloseButton: true,
            ),
            Expanded(
              child: Stack(
                children: [
                  // 表单内容
                  SingleChildScrollView(
                    key: const PageStorageKey<String>('kyc_submit_form'),
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 显示拒绝原因（如果有）
                          _buildRejectionReasonIfNeeded(),
                          // Level 1: 显示完整表单
                          if (widget.kycLevel == 1) ...[
                            _buildSection('个人基本信息', _buildBasicInfoSection()),
                            _buildSection('证件信息', _buildIdInfoSection()),
                            _buildSection('证件照片', _buildPhotoSection()),
                            _buildSection('地址信息', _buildAddressSection()),
                          ],
                          // Level 2: 只显示进阶认证所需的额外信息
                          if (widget.kycLevel == 2) ...[
                            _buildLevel2InfoCard(),
                            _buildSection('地址证明（进阶认证必填）', _buildAddressProofSection()),
                            const SizedBox(height: 24),
                            _buildLocationSection(),
                          ],
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // 提交中遮罩层
                  Observer(
                    builder: (_) {
                      return AnimatedOpacity(
                        opacity: _kycStore.isSubmitting ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !_kycStore.isSubmitting,
                          child: Container(
                            color: Colors.black45,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '正在提交认证信息...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建拒绝原因提示框（如果有拒绝原因）
  Widget _buildRejectionReasonIfNeeded() {
    // 获取当前等级的 KYC 记录
    final kyc = widget.kycLevel == 1 ? _kycStore.level1Kyc : _kycStore.level2Kyc;

    // 如果没有记录或状态不是拒绝状态，不显示
    if (kyc == null || !kyc.isRejected || kyc.remark == null || kyc.remark!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '认证审核未通过',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '拒绝原因：',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kyc.remark!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '请根据上述原因修改您的信息后重新提交',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /// 构建 Level 2 信息提示卡片
  Widget _buildLevel2InfoCard() {
    final level1Kyc = _kycStore.level1Kyc;
    final level2Kyc = _kycStore.level2Kyc;

    // 如果 level2Kyc 存在，说明之前已经提交过进阶认证，可以重新提交
    // 如果 level1Kyc 存在，说明标准认证已完成，可以首次提交进阶认证
    // 只有当两者都不存在时，才显示警告
    if (level1Kyc == null && level2Kyc == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, color: Colors.orange[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '进阶认证需要先完成标准认证，请返回先完成标准身份认证。',
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
    }

    // Level 1 或 Level 2 数据存在，显示正常的信息卡片

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level1Kyc != null ? '您的标准认证信息已自动填充' : '请补充以下进阶认证信息',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '进阶认证只需补充以下信息：\n1. 地址证明文件（水电费账单、银行对账单等）\n2. GPS定位信息',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 只有当 level1Kyc 存在时才显示信息摘要
        if (level1Kyc != null) ...[
          const SizedBox(height: 16),
          // 显示已填充的基本信息摘要
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    const Text(
                      '已提交的标准认证信息',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('姓名', level1Kyc.fullName),
                _buildInfoRow('性别', level1Kyc.genderText),
                if (level1Kyc.birthday != null) _buildInfoRow('出生日期', level1Kyc.birthday!),
                if (level1Kyc.idType != null && level1Kyc.idNumber != null)
                  _buildInfoRow('证件', '${level1Kyc.idTypeText} ${level1Kyc.maskedIdNumber}'),
                if (level1Kyc.address != null) _buildInfoRow('地址', level1Kyc.address!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildSelectField(
          label: '国家/地区 *',
          value: _selectedCountry.countryDisplayText,
          onTap: _showCountryPicker,
        ),
        const SizedBox(height: 16),
        _buildTextField(_surnameController, '姓 *', '请输入姓氏', required: true),
        const SizedBox(height: 16),
        _buildTextField(_middleNameController, '中间名（可选）', '如有中间名请输入'),
        const SizedBox(height: 16),
        _buildTextField(_nameController, '名 *', '请输入名字', required: true),
        const SizedBox(height: 16),
        _buildSelectField(
          label: '性别 *',
          value: _getGenderText(_selectedGender),
          onTap: _showGenderPicker,
          validator: (_) => _selectedGender == 0 ? '请选择性别' : null,
        ),
        const SizedBox(height: 16),
        _buildSelectField(
          label: '出生日期 *',
          value: _birthdayController.text.isEmpty ? '请选择出生日期' : _birthdayController.text,
          onTap: _showBirthdayPicker,
          validator: (_) => _birthday == null ? '请选择出生日期' : null,
        ),
      ],
    );
  }

  Widget _buildIdInfoSection() {
    return Column(
      children: [
        _buildSelectField(
          label: '证件类型 *',
          value: _getIdTypeText(_selectedIdType),
          onTap: _showIdTypePicker,
        ),
        const SizedBox(height: 16),
        _buildTextField(_idNumberController, '证件号码 *', '请输入证件号码', required: true),
        const SizedBox(height: 16),
        _buildSelectField(
          label: '证件签发日期 *',
          value: _idIssueDateController.text.isEmpty ? '请选择签发日期' : _idIssueDateController.text,
          onTap: _showIdIssueDatePicker,
          validator: (_) => _idIssueDate == null ? '请选择证件签发日期' : null,
        ),
        const SizedBox(height: 16),
        _buildSelectField(
          label: '证件有效期（可选）',
          value: _idExpiryDateController.text.isEmpty ? '请选择有效期' : _idExpiryDateController.text,
          onTap: _showIdExpiryDatePicker,
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        _buildPhotoUploadCard(
          title: '证件正面照片',
          description: '请上传证件正面清晰照片',
          imagePath: _idFrontImage,
          onTap: () => _pickImage((path) => setState(() => _idFrontImage = path)),
          required: true,
        ),
        const SizedBox(height: 12),
        _buildPhotoUploadCard(
          title: '证件背面照片',
          description: '请上传证件背面清晰照片',
          imagePath: _idBackImage,
          onTap: () => _pickImage((path) => setState(() => _idBackImage = path)),
          required: true,
        ),
        const SizedBox(height: 12),
        _buildPhotoUploadCard(
          title: '手持证件自拍照',
          description: '请手持证件拍摄清晰的自拍照',
          imagePath: _idSelfieImage,
          onTap: () => _pickImage((path) => setState(() => _idSelfieImage = path)),
          required: true,
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return TextFormField(
      controller: _addressController,
      decoration: _buildInputDecoration(
        labelText: '详细地址 *',
        hintText: '请输入您的详细地址',
      ),
      maxLines: 3,
      validator: (value) => value?.isEmpty ?? true ? '请输入详细地址' : null,
    );
  }

  Widget _buildAddressProofSection() {
    return _buildPhotoUploadCard(
      title: '地址证明文件',
      description: '请上传水电费账单、银行对账单等地址证明',
      imagePath: _addressProofImage,
      onTap: () => _pickImage((path) => setState(() => _addressProofImage = path)),
      required: widget.kycLevel == 2,
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text('GPS定位（进阶认证必填）', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Text('进阶认证需要提供真实的GPS定位信息以验证地址', style: TextStyle(fontSize: 13, color: Colors.blue[900])),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isLoadingLocation ? null : _getLocation,
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.my_location, size: 18),
            label: Text(_isLoadingLocation ? '定位中...' : '获取当前位置'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          if (_latitude != null && _longitude != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      const Text('定位成功', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('经度: ${_longitude!.toStringAsFixed(6)}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('纬度: ${_latitude!.toStringAsFixed(6)}', style: const TextStyle(fontSize: 13)),
                  if (_locationAccuracy != null) ...[
                    const SizedBox(height: 4),
                    Text('精度: ${_locationAccuracy!.toStringAsFixed(2)}米', style: const TextStyle(fontSize: 13)),
                  ],
                  if (_locationAddress != null) ...[
                    const SizedBox(height: 4),
                    Text('地址: $_locationAddress', style: const TextStyle(fontSize: 13)),
                  ],
                  if (_locationTime != null) ...[
                    const SizedBox(height: 4),
                    Text('时间: ${DateFormat(_dateTimeFormat).format(_locationTime!)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 显示确认对话框
          MessageService.confirm(
            title: '确认提交',
            message: widget.kycLevel == 1
                ? '请确认您填写的标准认证信息准确无误，提交后将进入审核流程。'
                : '请确认您填写的进阶认证信息准确无误，提交后将进入审核流程。',
            confirmText: '确认提交',
            cancelText: '再检查一下',
            confirmColor: Theme.of(context).primaryColor,
            onConfirm: () {
              // 用户确认后执行提交
              _submitForm();
            },
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          widget.kycLevel == 1 ? '提交标准认证' : '提交进阶认证',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(labelText: label, hintText: hint),
      validator: required ? (value) => value?.isEmpty ?? true ? '请输入$label' : null : null,
    );
  }

  Widget _buildSelectField({
    required String label,
    required String value,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: validator,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: InputDecorator(
                decoration: _buildInputDecoration(
                  labelText: label,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  errorText: formFieldState.errorText,
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.startsWith('请选择') ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoUploadCard({
    required String title,
    required String description,
    required String? imagePath,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: required && imagePath == null ? Colors.red[300]! : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: _photoSize,
              height: _photoSize,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        ImageUtils.formatSingleImagePath(imagePath),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null ? child : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.grey[400], size: 30),
                      ),
                    )
                  : Icon(Icons.add_photo_alternate, color: Colors.grey[400], size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (required) ...[
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(color: Colors.red, fontSize: 15)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(imagePath != null ? Icons.check_circle : Icons.chevron_right, color: imagePath != null ? Colors.green : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _getGenderText(int gender) => const {1: '男', 2: '女', 3: '其他'}[gender] ?? '';

  String _getIdTypeText(String idType) => const {
    'ID_CARD': '身份证',
    'PASSPORT': '护照',
    'DRIVING_LICENSE': '驾驶证',
    'OTHER': '其他',
  }[idType] ?? '';

  Future<void> _showGenderPicker() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _buildBottomSheet('选择性别', [
        _buildListItem(1, '男', Icons.male, _selectedGender == 1, () => _selectAndPop(() => _selectedGender = 1)),
        _buildListItem(2, '女', Icons.female, _selectedGender == 2, () => _selectAndPop(() => _selectedGender = 2)),
      ]),
    );
  }

  void _selectAndPop(VoidCallback onSelect) {
    setState(onSelect);
    Navigator.pop(context);
  }

  Future<void> _showCountryPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text('选择国家/地区', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              if (Countries.popular.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text('常用', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                ...Countries.popular.map((country) => _buildCountryItem(country)),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text('全部国家/地区', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: Countries.all.length,
                  itemBuilder: (context, index) => _buildCountryItem(Countries.all[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showIdTypePicker() async {
    final idTypes = [
      ('ID_CARD', '身份证', '中华人民共和国居民身份证', Icons.credit_card),
      ('PASSPORT', '护照', '国际旅行证件', Icons.travel_explore),
      ('DRIVING_LICENSE', '驾驶证', '机动车驾驶证', Icons.drive_eta),
      ('OTHER', '其他', '其他有效身份证件', Icons.description),
    ];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _buildBottomSheet(
        '选择证件类型',
        idTypes.map((item) => _buildIdTypeItem(item.$1, item.$2, item.$3, item.$4)).toList(),
      ),
    );
  }

  Future<void> _showBirthdayPicker() => _showDatePicker(
    title: '选择出生日期',
    initialDate: _birthday ?? DateTime(2000, 1, 1),
    firstDate: DateTime(1971),
    lastDate: DateTime.now(),
    onSelected: (date) {
      _birthday = date;
      _birthdayController.text = DateFormat(_dateFormat).format(date);
    },
  );

  Future<void> _showIdIssueDatePicker() => _showDatePicker(
    title: '选择证件签发日期',
    initialDate: _idIssueDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    onSelected: (date) {
      _idIssueDate = date;
      _idIssueDateController.text = DateFormat(_dateFormat).format(date);
    },
  );

  Future<void> _showIdExpiryDatePicker() => _showDatePicker(
    title: '选择证件有效期',
    initialDate: _idExpiryDate ?? DateTime.now().add(const Duration(days: 3650)),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
    onSelected: (date) {
      _idExpiryDate = date;
      _idExpiryDateController.text = DateFormat(_dateFormat).format(date);
    },
  );

  Future<void> _showDatePicker({
    required String title,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DateTime) onSelected,
  }) async {
    final result = await DatePickerBottomSheet.show(
      context,
      title: title,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (result != null) setState(() => onSelected(result));
  }

  Widget _buildBottomSheet(String title, List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...children,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildListItem(int value, String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 24, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20) : null,
      onTap: onTap,
    );
  }

  Widget _buildIdTypeItem(String value, String label, String description, IconData icon) {
    final isSelected = _selectedIdType == value;
    final primaryColor = Theme.of(context).primaryColor;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24, color: isSelected ? primaryColor : Colors.grey.shade600),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? primaryColor : Colors.black87,
        ),
      ),
      subtitle: Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: isSelected ? Icon(Icons.check_circle, color: primaryColor, size: 20) : null,
      onTap: () => _selectAndPop(() => _selectedIdType = value),
    );
  }

  Widget _buildCountryItem(CountryData country) {
    final isSelected = _selectedCountry.code == country.code;
    return ListTile(
      leading: Text(country.flag, style: const TextStyle(fontSize: 24.0)),
      title: Text(country.nameCn, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            country.code,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
          ],
        ],
      ),
      onTap: () {
        setState(() => _selectedCountry = country);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _pickImage(Function(String) onPicked) async {
    try {
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

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      final response = await _attachmentApi.upload(filePath: image.path);

      // 响应拦截器已处理错误，到这里说明上传成功
      final imagePath = response['url'] as String?;
      if (imagePath != null && imagePath.isNotEmpty) {
        onPicked(imagePath);
      } else {
        throw Exception('上传返回的图片路径为空');
      }
    } catch (e) {
      if (mounted) {
        MessageService.error('图片上传失败: ${e.toString()}');
      }
    }
  }

  Future<void> _getLocation() async {
    if (_isLoadingLocation) return;

    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('定位服务未启用，请在设置中开启定位服务');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('定位权限被拒绝');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('定位权限被永久拒绝，请在设置中手动开启');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('定位超时，请确保GPS已开启并在开阔区域。如果是模拟器，请先设置模拟位置'),
      );

      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> addressParts = [];
          if (place.country?.isNotEmpty ?? false) addressParts.add(place.country!);
          if (place.administrativeArea?.isNotEmpty ?? false) addressParts.add(place.administrativeArea!);
          if (place.locality?.isNotEmpty ?? false) addressParts.add(place.locality!);
          if (place.subLocality?.isNotEmpty ?? false) addressParts.add(place.subLocality!);
          if (place.street?.isNotEmpty ?? false) addressParts.add(place.street!);
          address = addressParts.join(' ');
        }
      } catch (e) {
        // 反地理编码失败不影响定位功能
      }

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationAccuracy = position.accuracy;
          _locationAddress = address;
          _locationTime = position.timestamp;
          _isLoadingLocation = false;
        });
        MessageService.success('定位成功');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        String errorMessage = e is Exception ? e.toString().replaceAll('Exception: ', '') : e.toString();
        MessageService.error(errorMessage);
      }
    }
  }

  Future<void> _submitForm() async {
    final errors = <String>[];

    // Level 1 验证
    if (widget.kycLevel == 1) {
      if (_surnameController.text.trim().isEmpty) errors.add('请输入姓氏');
      if (_nameController.text.trim().isEmpty) errors.add('请输入名字');
      if (_birthday == null) errors.add('请选择出生日期');
      if (_idNumberController.text.trim().isEmpty) errors.add('请输入证件号码');
      if (_idIssueDate == null) errors.add('请选择证件签发日期');
      if (_addressController.text.trim().isEmpty) errors.add('请输入详细地址');
      if (_idFrontImage == null) errors.add('请上传证件正面照片');
      if (_idBackImage == null) errors.add('请上传证件背面照片');
      if (_idSelfieImage == null) errors.add('请上传手持证件自拍照');
    }
    // Level 2 验证
    else {
      if (_kycStore.level2Kyc == null && _kycStore.level1Kyc == null) {
        MessageService.error('请先完成标准身份认证');
        return;
      }
      if (_addressProofImage == null) errors.add('请上传地址证明文件');
      if (_latitude == null || _longitude == null) errors.add('请获取GPS定位信息');
    }

    if (errors.isNotEmpty) {
      MessageService.error(errors.join('\n'));
      return;
    }

    try {
      await _kycStore.submitKyc(
        kycLevel: widget.kycLevel,
        countryCode: _selectedCountry.code,
        surname: _surnameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
        name: _nameController.text.trim(),
        gender: _selectedGender,
        birthday: _birthday != null ? DateFormat(_dateFormat).format(_birthday!) : '',
        idType: _selectedIdType,
        idNumber: _idNumberController.text.trim(),
        idIssueDate: _idIssueDate != null ? DateFormat(_dateFormat).format(_idIssueDate!) : '',
        idExpiryDate: _idExpiryDate != null ? DateFormat(_dateFormat).format(_idExpiryDate!) : null,
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        locationAccuracy: _locationAccuracy,
        locationAddress: _locationAddress,
        locationTime: _locationTime != null ? DateFormat(_dateTimeFormat).format(_locationTime!) : null,
        idFrontImage: _idFrontImage!,
        idBackImage: _idBackImage!,
        idSelfieImage: _idSelfieImage!,
        addressProofImage: _addressProofImage,
      );

      // 提交成功后刷新用户信息（更新 is_kyc 状态）
      final userStore = getIt<UserStore>();
      await userStore.getUserInfo();

      if (mounted) {
        MessageService.success(widget.kycLevel == 1 ? '标准认证信息已提交成功' : '进阶认证信息已提交成功');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        MessageService.error(e.toString());
      }
    }
  }
}
