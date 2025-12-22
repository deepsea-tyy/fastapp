import '../../../core/domain/usecase/use_case.dart';
import '../../entity/market/currency_detail.dart';
import '../../repository/market_repository.dart';

/// 获取币种详情的参数
class GetCurrencyDetailParams {
  final String symbol;

  GetCurrencyDetailParams({required this.symbol});
}

/// 获取币种详情 UseCase
class GetCurrencyDetailUseCase implements UseCase<CurrencyDetail?, GetCurrencyDetailParams> {
  final MarketRepository _marketRepository;

  GetCurrencyDetailUseCase(this._marketRepository);

  @override
  Future<CurrencyDetail?> call({required GetCurrencyDetailParams params}) async {
    if (params.symbol.isEmpty) {
      return null;
    }
    return _marketRepository.getCurrencyDetail(symbol: params.symbol);
  }
}

