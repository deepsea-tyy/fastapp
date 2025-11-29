import '../../../core/domain/usecase/use_case.dart';
import '../../entity/wallet/asset.dart';
import '../../entity/wallet/balance.dart';
import '../../repository/wallet_repository.dart';

/// 获取资产UseCase
class GetAssetUseCase implements UseCase<Asset, void> {
  final WalletRepository _walletRepository;

  GetAssetUseCase(this._walletRepository);

  @override
  Future<Asset> call({required params}) async {
    return _walletRepository.getAsset();
  }
}

/// 获取余额的参数
class GetBalanceParams {
  final String currency;

  GetBalanceParams({required this.currency});
}

/// 获取余额UseCase
class GetBalanceUseCase implements UseCase<Balance?, GetBalanceParams> {
  final WalletRepository _walletRepository;

  GetBalanceUseCase(this._walletRepository);

  @override
  Future<Balance?> call({required GetBalanceParams params}) async {
    return _walletRepository.getBalanceByCurrency(params.currency);
  }
}

