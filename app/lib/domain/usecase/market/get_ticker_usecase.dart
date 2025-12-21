import '../../../core/domain/usecase/use_case.dart';
import '../../entity/market/ticker_data.dart';
import '../../repository/market_repository.dart';

/// 获取Ticker数据的参数
class GetTickerParams {
  final String? symbol;

  GetTickerParams({this.symbol});
}

/// 获取TickerUseCase
class GetTickerUseCase implements UseCase<TickerData?, GetTickerParams> {
  final MarketRepository _marketRepository;

  GetTickerUseCase(this._marketRepository);

  @override
  Future<TickerData?> call({required GetTickerParams params}) async {
    return params.symbol != null
        ? _marketRepository.getTickerData(symbol: params.symbol)
        : null;
  }
}

/// 获取所有Ticker数据的参数
class GetAllTickerParams {
  final List<String>? symbols;

  GetAllTickerParams({this.symbols});
}

/// 获取所有TickerUseCase
class GetAllTickerUseCase implements UseCase<List<TickerData>, GetAllTickerParams> {
  final MarketRepository _marketRepository;

  GetAllTickerUseCase(this._marketRepository);

  @override
  Future<List<TickerData>> call({required GetAllTickerParams params}) async {
    return _marketRepository.getAllTickerData(symbols: params.symbols);
  }
}

