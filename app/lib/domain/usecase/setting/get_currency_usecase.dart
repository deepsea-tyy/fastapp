import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 获取币种 UseCase
class GetCurrencyUseCase implements UseCase<String?, void> {
  final SettingRepository _repository;

  GetCurrencyUseCase(this._repository);

  @override
  Future<String?> call({required params}) async {
    return _repository.currentCurrency;
  }
}
