import '../../../core/domain/usecase/use_case.dart';
import '../../entity/market/depth_data.dart';
import '../../repository/market_repository.dart';

/// 获取深度数据的参数
class GetDepthParams {
  final String symbol;
  final int? limit;

  GetDepthParams({
    required this.symbol,
    this.limit,
  });
}

/// 获取深度UseCase
class GetDepthUseCase implements UseCase<DepthChartData, GetDepthParams> {
  final MarketRepository _marketRepository;

  GetDepthUseCase(this._marketRepository);

  @override
  Future<DepthChartData> call({required GetDepthParams params}) async {
    return _marketRepository.getDepthData(
      symbol: params.symbol,
      limit: params.limit,
    );
  }
}

