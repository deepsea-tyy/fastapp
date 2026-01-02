import '../../../core/domain/usecase/use_case.dart';
import '../../entity/market/kline_data.dart';
import '../../repository/market_repository.dart';

/// 获取K线数据的参数
class GetKlineParams {
  final String symbol;
  final String interval;
  final int? page;
  final int? pageSize;

  GetKlineParams({
    required this.symbol,
    required this.interval,
    this.page,
    this.pageSize,
  });
}

/// 获取K线UseCase
class GetKlineUseCase implements UseCase<List<KlineData>, GetKlineParams> {
  final MarketRepository _marketRepository;

  GetKlineUseCase(this._marketRepository);

  @override
  Future<List<KlineData>> call({required GetKlineParams params}) async {
    return _marketRepository.getKlineData(
      symbol: params.symbol,
      interval: params.interval,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

