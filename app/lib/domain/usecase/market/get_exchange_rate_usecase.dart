import '../../../core/domain/usecase/use_case.dart';
import '../../entity/market/exchange_rate_response.dart';
import '../../repository/market_repository.dart';

/// 获取汇率 UseCase
class GetExchangeRateUseCase implements UseCase<ExchangeRateResponse?, void> {
  final MarketRepository _marketRepository;

  GetExchangeRateUseCase(this._marketRepository);

  @override
  Future<ExchangeRateResponse?> call({required void params}) {
    return _marketRepository.getExchangeRate();
  }
}
