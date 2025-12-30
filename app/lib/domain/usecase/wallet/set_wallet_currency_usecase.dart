import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 设置钱包显示币种参数
class SetWalletCurrencyParams {
  final String currency;

  SetWalletCurrencyParams({required this.currency});
}

/// 设置钱包显示币种 UseCase
class SetWalletCurrencyUseCase implements UseCase<void, SetWalletCurrencyParams> {
  final SettingRepository _repository;

  SetWalletCurrencyUseCase(this._repository);

  @override
  Future<void> call({required SetWalletCurrencyParams params}) async {
    return _repository.changeWalletCurrency(params.currency);
  }
}
