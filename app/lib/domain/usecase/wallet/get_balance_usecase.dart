import '../../../core/domain/usecase/use_case.dart';
import '../../entity/wallet/asset.dart';
import '../../entity/wallet/balance.dart';
import '../../repository/wallet_repository.dart';

class GetAssetUseCase implements UseCase<Asset, void> {
  final WalletRepository _repository;

  GetAssetUseCase(this._repository);

  @override
  Future<Asset> call({required params}) => _repository.getAsset();
}

class GetBalanceParams {
  final String currency;

  GetBalanceParams({required this.currency});
}

class GetBalanceUseCase implements UseCase<Balance?, GetBalanceParams> {
  final WalletRepository _repository;

  GetBalanceUseCase(this._repository);

  @override
  Future<Balance?> call({required GetBalanceParams params}) =>
      _repository.getBalanceByCurrency(params.currency);
}

