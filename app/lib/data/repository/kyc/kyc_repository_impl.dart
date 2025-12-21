import '../../network/apis/kyc/ex_kyc_api.dart';
import '../../../domain/repository/kyc/kyc_repository.dart';

/// KYC认证仓库实现
class KycRepositoryImpl implements KycRepository {
  final ExKycApi _kycApi;

  KycRepositoryImpl(this._kycApi);

  @override
  Future<Map<String, dynamic>> getKycDetail({int? kycLevel}) async {
    return await _kycApi.getKycDetail(kycLevel: kycLevel);
  }

  @override
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
    return await _kycApi.submitKyc(
      kycLevel: kycLevel,
      countryCode: countryCode,
      surname: surname,
      middleName: middleName,
      name: name,
      gender: gender,
      birthday: birthday,
      idType: idType,
      idNumber: idNumber,
      idIssueDate: idIssueDate,
      idExpiryDate: idExpiryDate,
      address: address,
      latitude: latitude,
      longitude: longitude,
      locationAccuracy: locationAccuracy,
      locationAddress: locationAddress,
      locationTime: locationTime,
      idFrontImage: idFrontImage,
      idBackImage: idBackImage,
      idSelfieImage: idSelfieImage,
      addressProofImage: addressProofImage,
    );
  }
}

