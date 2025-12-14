import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// KYC认证API实现
class ExKycApi {
  final DioClient _dioClient;

  ExKycApi(this._dioClient);

  /// 提交KYC认证申请
  /// [kycLevel] 认证等级：1=标准认证,2=进阶认证(KYC)
  /// [countryCode] 国家/地区代码（ISO 3166-1 alpha-2）
  /// [surname] 姓
  /// [middleName] 中间名（可选）
  /// [name] 名字
  /// [gender] 性别：1=男,2=女,3=其他
  /// [birthday] 出生日期（格式：YYYY-MM-DD）
  /// [idType] 证件类型：ID_CARD=身份证,PASSPORT=护照,DRIVING_LICENSE=驾驶证,OTHER=其他
  /// [idNumber] 身份证件号码
  /// [idIssueDate] 证件签发日期（格式：YYYY-MM-DD）
  /// [idExpiryDate] 证件有效期（格式：YYYY-MM-DD，可选）
  /// [address] 地址信息
  /// [latitude] GPS纬度（可选）
  /// [longitude] GPS经度（可选）
  /// [locationAccuracy] 定位精度（米，可选）
  /// [locationAddress] GPS反地理编码地址（可选）
  /// [locationTime] 定位时间（格式：YYYY-MM-DD HH:mm:ss，可选）
  /// [idFrontImage] 证件正面照片URL
  /// [idBackImage] 证件背面照片URL
  /// [idSelfieImage] 手持证件自拍照片URL
  /// [addressProofImage] 地址证明照片URL（进阶认证必填）
  Future<Map<String, dynamic>> submitKyc({
    required int kycLevel,
    required String countryCode,
    required String surname,
    String? middleName,
    required String name,
    required int gender,
    required String birthday,
    required String idType,
    required String idNumber,
    required String idIssueDate,
    String? idExpiryDate,
    required String address,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    String? locationAddress,
    String? locationTime,
    required String idFrontImage,
    required String idBackImage,
    required String idSelfieImage,
    String? addressProofImage,
  }) async {
    final data = <String, dynamic>{
      'kyc_level': kycLevel,
      'country_code': countryCode,
      'surname': surname,
      'name': name,
      'gender': gender,
      'birthday': birthday,
      'id_type': idType,
      'id_number': idNumber,
      'id_issue_date': idIssueDate,
      'address': address,
      'id_front_image': idFrontImage,
      'id_back_image': idBackImage,
      'id_selfie_image': idSelfieImage,
    };

    // 可选参数
    if (middleName != null && middleName.isNotEmpty) {
      data['middle_name'] = middleName;
    }
    if (idExpiryDate != null && idExpiryDate.isNotEmpty) {
      data['id_expiry_date'] = idExpiryDate;
    }
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (locationAccuracy != null) data['location_accuracy'] = locationAccuracy;
    if (locationAddress != null && locationAddress.isNotEmpty) {
      data['location_address'] = locationAddress;
    }
    if (locationTime != null && locationTime.isNotEmpty) {
      data['location_time'] = locationTime;
    }
    if (addressProofImage != null && addressProofImage.isNotEmpty) {
      data['address_proof_image'] = addressProofImage;
    }

    final response = await _dioClient.dio.post(
      Endpoints.kycSubmit,
      data: data,
    );
    return response.data;
  }

  /// 获取KYC详情
  /// [kycLevel] 认证等级（可选），不传则返回最高等级的记录
  Future<Map<String, dynamic>> getKycDetail({int? kycLevel}) async {
    final queryParameters = <String, dynamic>{};
    if (kycLevel != null) {
      queryParameters['kyc_level'] = kycLevel;
    }

    final response = await _dioClient.dio.get(
      Endpoints.kycDetail,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return response.data;
  }
}
