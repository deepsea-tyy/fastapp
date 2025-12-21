import '../../../core/domain/usecase/use_case.dart';
import '../../repository/futures_repository.dart';

/// 设置杠杆参数
class SetLeverageParams {
  final String symbol;
  final int leverage;

  SetLeverageParams({required this.symbol, required this.leverage});
}

/// 设置杠杆 UseCase
class SetLeverageUseCase implements UseCase<bool, SetLeverageParams> {
  final FuturesRepository _repository;

  SetLeverageUseCase(this._repository);

  @override
  Future<bool> call({required SetLeverageParams params}) async {
    return await _repository.setLeverage(params.symbol, params.leverage);
  }
}

