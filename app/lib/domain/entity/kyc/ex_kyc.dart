import 'package:json_annotation/json_annotation.dart';

part 'ex_kyc.g.dart';

@JsonSerializable()
class ExKyc {
  final int? id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'kyc_level')
  final int kycLevel; // 1=标准认证,2=进阶认证(KYC)
  @JsonKey(name: 'country_code')
  final String? countryCode;
  final String? surname;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  final String? name;
  final int? gender; // 1=男,2=女,3=其他
  final String? birthday;
  @JsonKey(name: 'id_type')
  final String? idType; // ID_CARD,PASSPORT,DRIVING_LICENSE,OTHER
  @JsonKey(name: 'id_number')
  final String? idNumber;
  @JsonKey(name: 'id_issue_date')
  final String? idIssueDate;
  @JsonKey(name: 'id_expiry_date')
  final String? idExpiryDate;
  final String? address;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'location_accuracy')
  final double? locationAccuracy;
  @JsonKey(name: 'location_time')
  final String? locationTime;
  @JsonKey(name: 'location_address')
  final String? locationAddress;
  @JsonKey(name: 'id_front_image')
  final String? idFrontImage;
  @JsonKey(name: 'id_back_image')
  final String? idBackImage;
  @JsonKey(name: 'id_selfie_image')
  final String? idSelfieImage;
  @JsonKey(name: 'address_proof_image')
  final String? addressProofImage;
  final int status; // 0=待审核,1=审核中,2=已通过,3=已拒绝,4=已取消
  @JsonKey(name: 'ocr_result')
  final Map<String, dynamic>? ocrResult;
  @JsonKey(name: 'ocr_confidence')
  final double? ocrConfidence;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ExKyc({
    this.id,
    required this.userId,
    required this.kycLevel,
    this.countryCode,
    this.surname,
    this.middleName,
    this.name,
    this.gender,
    this.birthday,
    this.idType,
    this.idNumber,
    this.idIssueDate,
    this.idExpiryDate,
    this.address,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.locationTime,
    this.locationAddress,
    this.idFrontImage,
    this.idBackImage,
    this.idSelfieImage,
    this.addressProofImage,
    required this.status,
    this.ocrResult,
    this.ocrConfidence,
    this.createdAt,
    this.updatedAt,
  });

  factory ExKyc.fromJson(Map<String, dynamic> json) => _$ExKycFromJson(json);

  Map<String, dynamic> toJson() => _$ExKycToJson(this);

  /// 获取状态文本
  String get statusText {
    switch (status) {
      case 0:
        return '待审核';
      case 1:
        return '审核中';
      case 2:
        return '已通过';
      case 3:
        return '已拒绝';
      case 4:
        return '已取消';
      default:
        return '未知';
    }
  }

  /// 获取认证等级文本
  String get kycLevelText {
    switch (kycLevel) {
      case 1:
        return '标准身份认证';
      case 2:
        return '进阶身份认证';
      default:
        return '未知等级';
    }
  }

  /// 获取证件类型文本
  String get idTypeText {
    switch (idType) {
      case 'ID_CARD':
        return '身份证';
      case 'PASSPORT':
        return '护照';
      case 'DRIVING_LICENSE':
        return '驾驶证';
      case 'OTHER':
        return '其他';
      default:
        return '未知';
    }
  }

  /// 获取性别文本
  String get genderText {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      case 3:
        return '其他';
      default:
        return '未知';
    }
  }

  /// 获取完整姓名
  String get fullName {
    final parts = <String>[];
    if (surname != null && surname!.isNotEmpty) parts.add(surname!);
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    if (name != null && name!.isNotEmpty) parts.add(name!);
    return parts.join(' ');
  }

  /// 获取脱敏后的证件号码
  String get maskedIdNumber {
    if (idNumber == null || idNumber!.length < 6) return idNumber ?? '';
    return '${idNumber!.substring(0, 2)}${'*' * (idNumber!.length - 4)}${idNumber!.substring(idNumber!.length - 2)}';
  }

  /// 是否已通过认证
  bool get isApproved => status == 2;

  /// 是否待审核或审核中
  bool get isPending => status == 0 || status == 1;

  /// 是否已拒绝
  bool get isRejected => status == 3;
}
