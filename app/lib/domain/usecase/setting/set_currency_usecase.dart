import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 设置币种参数
class SetCurrencyParams {
  final String currency;

  SetCurrencyParams({required this.currency});
}

/// 设置币种 UseCase
class SetCurrencyUseCase implements UseCase<void, SetCurrencyParams> {
  final SettingRepository _repository;

  SetCurrencyUseCase(this._repository);

  @override
  Future<void> call({required SetCurrencyParams params}) async {
    return _repository.changeCurrency(params.currency);
  }
}
