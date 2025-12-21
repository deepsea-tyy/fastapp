import '../../../core/domain/usecase/use_case.dart';
import '../../entity/futures/leverage.dart';
import '../../repository/futures_repository.dart';

/// 获取杠杆参数
class GetLeverageParams {
  final String symbol;

  GetLeverageParams({required this.symbol});
}

/// 获取杠杆 UseCase
class GetLeverageUseCase implements UseCase<Leverage?, GetLeverageParams> {
  final FuturesRepository _repository;

  GetLeverageUseCase(this._repository);

  @override
  Future<Leverage?> call({required GetLeverageParams params}) async {
    return await _repository.getLeverage(params.symbol);
  }
}

