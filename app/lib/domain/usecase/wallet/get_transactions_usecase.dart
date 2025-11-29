import '../../../core/domain/usecase/use_case.dart';
import '../../entity/wallet/transaction.dart';
import '../../repository/wallet_repository.dart';

/// 获取交易记录列表的参数
class GetTransactionsParams {
  final String? currency;
  final TransactionType? type;
  final int? startTime;
  final int? endTime;
  final int? limit;

  GetTransactionsParams({
    this.currency,
    this.type,
    this.startTime,
    this.endTime,
    this.limit,
  });
}

/// 获取交易记录列表UseCase
class GetTransactionsUseCase
    implements UseCase<List<Transaction>, GetTransactionsParams> {
  final WalletRepository _walletRepository;

  GetTransactionsUseCase(this._walletRepository);

  @override
  Future<List<Transaction>> call({required GetTransactionsParams params}) async {
    return _walletRepository.getTransactions(
      currency: params.currency,
      type: params.type,
      startTime: params.startTime,
      endTime: params.endTime,
      limit: params.limit,
    );
  }
}

