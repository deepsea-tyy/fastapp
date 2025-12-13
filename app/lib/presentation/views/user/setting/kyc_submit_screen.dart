import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/store/kyc/ex_kyc_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'widgets.dart';

/// KYC认证提交页面
class KycSubmitScreen extends StatefulWidget {
  final int kycLevel; // 1=标准认证, 2=进阶认证

  const KycSubmitScreen({
    super.key,
    required this.kycLevel,
  });

  @override
  State<KycSubmitScreen> createState() => _KycSubmitScreenState();
}

class _KycSubmitScreenState extends State<KycSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userStore = getIt<UserStore>();
  final _kycStore = getIt<ExKycStore>();

  // 表单控制器
  final _countryCodeController = TextEditingController();
  final _surnameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _idIssueDateController = TextEditingController();
  final _idExpiryDateController = TextEditingController();
  final _addressController = TextEditingController();

  // 表单数据
  int _selectedGender = 1; // 1=男, 2=女, 3=其他
  String _selectedIdType = 'ID_CARD'; // ID_CARD, PASSPORT, DRIVING_LICENSE, OTHER
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

  @override
  void initState() {
    super.initState();
    // 初始化默认值
    _countryCodeController.text = 'CN'; // 默认中国
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SettingAppBar(
              title: widget.kycLevel == 1 ? '标准身份认证' : '进阶身份认证',
              showCloseButton: true,
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_kycStore.isSubmitting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在提交认证信息...'),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('个人基本信息'),
                          _buildBasicInfoSection(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('证件信息'),
                          _buildIdInfoSection(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('证件照片'),
                          _buildPhotoSection(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('地址信息'),
                          _buildAddressSection(),
                          if (widget.kycLevel == 2) ...[
                            const SizedBox(height: 24),
                            _buildSectionTitle('地址证明（进阶认证必填）'),
                            _buildAddressProofSection(),
                          ],
                          const SizedBox(height: 24),
                          _buildLocationSection(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
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

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建基本信息区域
  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        // 国家/地区代码
        TextFormField(
          controller: _countryCodeController,
          decoration: const InputDecoration(
            labelText: '国家/地区代码 *',
            hintText: '请输入国家代码，如：CN',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入国家/地区代码';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // 姓
        TextFormField(
          controller: _surnameController,
          decoration: const InputDecoration(
            labelText: '姓 *',
            hintText: '请输入姓氏',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入姓氏';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // 中间名（可选）
        TextFormField(
          controller: _middleNameController,
          decoration: const InputDecoration(
            labelText: '中间名（可选）',
            hintText: '如有中间名请输入',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        // 名
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '名 *',
            hintText: '请输入名字',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入名字';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // 性别
        DropdownButtonFormField<int>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: '性别 *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('男')),
            DropdownMenuItem(value: 2, child: Text('女')),
            DropdownMenuItem(value: 3, child: Text('其他')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedGender = value);
            }
          },
        ),
        const SizedBox(height: 16),
        // 出生日期
        TextFormField(
          controller: _birthdayController,
          decoration: const InputDecoration(
            labelText: '出生日期 *',
            hintText: '请选择出生日期',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(
            context,
            _birthday,
            (date) {
              setState(() {
                _birthday = date;
                _birthdayController.text =
                    DateFormat('yyyy-MM-dd').format(date);
              });
            },
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请选择出生日期';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 构建证件信息区域
  Widget _buildIdInfoSection() {
    return Column(
      children: [
        // 证件类型
        DropdownButtonFormField<String>(
          value: _selectedIdType,
          decoration: const InputDecoration(
            labelText: '证件类型 *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'ID_CARD', child: Text('身份证')),
            DropdownMenuItem(value: 'PASSPORT', child: Text('护照')),
            DropdownMenuItem(value: 'DRIVING_LICENSE', child: Text('驾驶证')),
            DropdownMenuItem(value: 'OTHER', child: Text('其他')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedIdType = value);
            }
          },
        ),
        const SizedBox(height: 16),
        // 证件号码
        TextFormField(
          controller: _idNumberController,
          decoration: const InputDecoration(
            labelText: '证件号码 *',
            hintText: '请输入证件号码',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入证件号码';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // 证件签发日期
        TextFormField(
          controller: _idIssueDateController,
          decoration: const InputDecoration(
            labelText: '证件签发日期 *',
            hintText: '请选择签发日期',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(
            context,
            _idIssueDate,
            (date) {
              setState(() {
                _idIssueDate = date;
                _idIssueDateController.text =
                    DateFormat('yyyy-MM-dd').format(date);
              });
            },
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请选择证件签发日期';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // 证件有效期（可选）
        TextFormField(
          controller: _idExpiryDateController,
          decoration: const InputDecoration(
            labelText: '证件有效期（可选）',
            hintText: '请选择有效期',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(
            context,
            _idExpiryDate,
            (date) {
              setState(() {
                _idExpiryDate = date;
                _idExpiryDateController.text =
                    DateFormat('yyyy-MM-dd').format(date);
              });
            },
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          ),
        ),
      ],
    );
  }

  /// 构建照片上传区域
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

  /// 构建地址信息区域
  Widget _buildAddressSection() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: '详细地址 *',
        hintText: '请输入您的详细地址',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入详细地址';
        }
        return null;
      },
    );
  }

  /// 构建地址证明区域（进阶认证）
  Widget _buildAddressProofSection() {
    return _buildPhotoUploadCard(
      title: '地址证明文件',
      description: '请上传水电费账单、银行对账单等地址证明',
      imagePath: _addressProofImage,
      onTap: () => _pickImage((path) => setState(() => _addressProofImage = path)),
      required: widget.kycLevel == 2,
    );
  }

  /// 构建定位信息区域
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
              const Text(
                'GPS定位（可选）',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '为提高审核通过率，建议开启GPS定位',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _getLocation,
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('获取当前位置'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '经度: ${_longitude!.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '纬度: ${_latitude!.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (_locationAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '地址: $_locationAddress',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建照片上传卡片
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
          border: Border.all(
            color: required && imagePath == null
                ? Colors.red[300]!
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.add_photo_alternate,
                      color: Colors.grey[400],
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (required) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(color: Colors.red, fontSize: 15),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              imagePath != null ? Icons.check_circle : Icons.chevron_right,
              color: imagePath != null ? Colors.green : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '提交认证',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 选择日期
  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime) onSelect, {
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date != null) {
      onSelect(date);
    }
  }

  /// 选择图片
  Future<void> _pickImage(Function(String) onPicked) async {
    // TODO: 实现图片选择和上传
    // 这里应该集成 image_picker 和文件上传服务
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片选择功能待实现')),
    );

    // 模拟上传成功，返回URL
    // onPicked('https://example.com/uploaded-image.jpg');
  }

  /// 获取GPS定位
  Future<void> _getLocation() async {
    // TODO: 实现GPS定位
    // 这里应该集成 geolocator 包
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GPS定位功能待实现')),
    );

    // 模拟定位成功
    setState(() {
      _latitude = 39.9042;
      _longitude = 116.4074;
      _locationAccuracy = 10.0;
      _locationAddress = '北京市东城区天安门广场';
    });
  }

  /// 提交表单
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证必填照片
    if (_idFrontImage == null) {
      _showError('请上传证件正面照片');
      return;
    }
    if (_idBackImage == null) {
      _showError('请上传证件背面照片');
      return;
    }
    if (_idSelfieImage == null) {
      _showError('请上传手持证件自拍照');
      return;
    }
    if (widget.kycLevel == 2 && _addressProofImage == null) {
      _showError('进阶认证需要上传地址证明文件');
      return;
    }

    try {
      await _kycStore.submitKyc(
        kycLevel: widget.kycLevel,
        countryCode: _countryCodeController.text,
        surname: _surnameController.text,
        middleName: _middleNameController.text.isEmpty
            ? null
            : _middleNameController.text,
        name: _nameController.text,
        gender: _selectedGender,
        birthday: DateFormat('yyyy-MM-dd').format(_birthday!),
        idType: _selectedIdType,
        idNumber: _idNumberController.text,
        idIssueDate: DateFormat('yyyy-MM-dd').format(_idIssueDate!),
        idExpiryDate: _idExpiryDate != null
            ? DateFormat('yyyy-MM-dd').format(_idExpiryDate!)
            : null,
        address: _addressController.text,
        latitude: _latitude,
        longitude: _longitude,
        locationAccuracy: _locationAccuracy,
        locationAddress: _locationAddress,
        idFrontImage: _idFrontImage!,
        idBackImage: _idBackImage!,
        idSelfieImage: _idSelfieImage!,
        addressProofImage: _addressProofImage,
      );

      if (mounted) {
        // 提交成功，返回上一页
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('认证信息已提交，请等待审核'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  /// 显示错误提示
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
