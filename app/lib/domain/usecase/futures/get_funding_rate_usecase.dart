import '../../../core/domain/usecase/use_case.dart';
import '../../entity/futures/funding_rate.dart';
import '../../repository/futures_repository.dart';

/// 获取资金费率参数
class GetFundingRateParams {
  final String? symbol;

  GetFundingRateParams({this.symbol});
}

/// 获取资金费率 UseCase
class GetFundingRateUseCase implements UseCase<FundingRate?, GetFundingRateParams> {
  final FuturesRepository _repository;

  GetFundingRateUseCase(this._repository);

  @override
  Future<FundingRate?> call({required GetFundingRateParams params}) async {
    return await _repository.getFundingRate(symbol: params.symbol);
  }
}

