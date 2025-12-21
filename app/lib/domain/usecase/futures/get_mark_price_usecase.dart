import '../../../core/domain/usecase/use_case.dart';
import '../../entity/futures/mark_price.dart';
import '../../repository/futures_repository.dart';

/// 获取标记价格参数
class GetMarkPriceParams {
  final String? symbol;

  GetMarkPriceParams({this.symbol});
}

/// 获取标记价格 UseCase
class GetMarkPriceUseCase implements UseCase<MarkPrice?, GetMarkPriceParams> {
  final FuturesRepository _repository;

  GetMarkPriceUseCase(this._repository);

  @override
  Future<MarkPrice?> call({required GetMarkPriceParams params}) async {
    return await _repository.getMarkPrice(symbol: params.symbol);
  }
}

