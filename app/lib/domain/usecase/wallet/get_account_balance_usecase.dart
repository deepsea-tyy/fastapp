import '../../../core/domain/usecase/use_case.dart';
import '../../entity/wallet/account_balance.dart';
import '../../repository/wallet_repository.dart';

class GetAccountBalanceUseCase implements UseCase<AccountBalance, void> {
  final WalletRepository _repository;

  GetAccountBalanceUseCase(this._repository);

  @override
  Future<AccountBalance> call({required params}) =>
      _repository.getAccountBalance();
}
