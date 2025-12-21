import '../../../core/domain/usecase/use_case.dart';
import '../../repository/kyc/kyc_repository.dart';

/// 获取KYC详情参数
class GetKycDetailParams {
  final int? kycLevel;

  GetKycDetailParams({this.kycLevel});
}

/// 获取KYC详情 UseCase
class GetKycDetailUseCase implements UseCase<Map<String, dynamic>, GetKycDetailParams> {
  final KycRepository _repository;

  GetKycDetailUseCase(this._repository);

  @override
  Future<Map<String, dynamic>> call({required GetKycDetailParams params}) async {
    return await _repository.getKycDetail(kycLevel: params.kycLevel);
  }
}

