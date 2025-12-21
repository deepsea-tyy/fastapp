import '../../../core/domain/usecase/use_case.dart';
import '../../repository/kyc/kyc_repository.dart';

/// 提交KYC参数
class SubmitKycParams {
  final int kycLevel;
  final String countryCode;
  final String surname;
  final String? middleName;
  final String name;
  final int gender;
  final String birthday;
  final String idType;
  final String idNumber;
  final String idIssueDate;
  final String? idExpiryDate;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final String? locationAddress;
  final String? locationTime;
  final String idFrontImage;
  final String idBackImage;
  final String idSelfieImage;
  final String? addressProofImage;

  SubmitKycParams({
    required this.kycLevel,
    required this.countryCode,
    required this.surname,
    this.middleName,
    required this.name,
    required this.gender,
    required this.birthday,
    required this.idType,
    required this.idNumber,
    required this.idIssueDate,
    this.idExpiryDate,
    required this.address,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.locationAddress,
    this.locationTime,
    required this.idFrontImage,
    required this.idBackImage,
    required this.idSelfieImage,
    this.addressProofImage,
  });
}

/// 提交KYC UseCase
class SubmitKycUseCase implements UseCase<Map<String, dynamic>, SubmitKycParams> {
  final KycRepository _repository;

  SubmitKycUseCase(this._repository);

  @override
  Future<Map<String, dynamic>> call({required SubmitKycParams params}) async {
    return await _repository.submitKyc(
      kycLevel: params.kycLevel,
      countryCode: params.countryCode,
      surname: params.surname,
      middleName: params.middleName,
      name: params.name,
      gender: params.gender,
      birthday: params.birthday,
      idType: params.idType,
      idNumber: params.idNumber,
      idIssueDate: params.idIssueDate,
      idExpiryDate: params.idExpiryDate,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
      locationAccuracy: params.locationAccuracy,
      locationAddress: params.locationAddress,
      locationTime: params.locationTime,
      idFrontImage: params.idFrontImage,
      idBackImage: params.idBackImage,
      idSelfieImage: params.idSelfieImage,
      addressProofImage: params.addressProofImage,
    );
  }
}

