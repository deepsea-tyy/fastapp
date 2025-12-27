import '../entity/wallet/account_balance.dart';
import '../entity/wallet/asset.dart';
import '../entity/wallet/balance.dart';
import '../entity/wallet/transaction.dart';

abstract class WalletRepository {
  Future<AccountBalance> getAccountBalance();

  Future<Asset> getAsset();

  Future<Balance?> getBalanceByCurrency(String currency);

  Future<List<Transaction>> getTransactions({
    String? currency,
    TransactionType? type,
    int? startTime,
    int? endTime,
    int? limit,
  });

  Future<Transaction?> getTransactionById(String transactionId);
}

