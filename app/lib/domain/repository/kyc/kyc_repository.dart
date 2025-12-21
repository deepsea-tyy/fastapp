import '../../entity/kyc/ex_kyc.dart';

/// KYC认证仓库接口
abstract class KycRepository {
  /// 获取KYC详情
  /// [kycLevel] 认证等级（可选），不传则返回所有等级的记录
  Future<Map<String, dynamic>> getKycDetail({int? kycLevel});

  /// 提交KYC认证申请
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
  });
}

