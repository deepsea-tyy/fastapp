import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 获取钱包显示币种 UseCase
class GetWalletCurrencyUseCase implements UseCase<String?, void> {
  final SettingRepository _repository;

  GetWalletCurrencyUseCase(this._repository);

  @override
  Future<String?> call({required params}) async {
    return _repository.walletCurrency;
  }
}
