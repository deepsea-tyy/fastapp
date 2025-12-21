import '../../../core/domain/usecase/use_case.dart';
import '../../entity/futures/position.dart';
import '../../repository/futures_repository.dart';

/// 获取持仓参数
class GetPositionsParams {
  final String? symbol;

  GetPositionsParams({this.symbol});
}

/// 获取持仓 UseCase
class GetPositionsUseCase implements UseCase<List<Position>, GetPositionsParams> {
  final FuturesRepository _repository;

  GetPositionsUseCase(this._repository);

  @override
  Future<List<Position>> call({required GetPositionsParams params}) async {
    return await _repository.getPositions(symbol: params.symbol);
  }
}

