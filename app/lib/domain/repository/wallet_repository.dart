import '../entity/wallet/account_balance.dart';
import '../entity/wallet/asset.dart';
import '../entity/wallet/balance.dart';
import '../entity/wallet/balance_log.dart';
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

  Future<List<BalanceLog>> getBalanceLogs({
    String? walletType,
    String? symbol,
    String? changeType,
    int? startTime,
    int? endTime,
    int page = 1,
    int pageSize = 20,
  });

  Future<void> transfer({
    required String fromWalletType,
    required String toWalletType,
    required String symbol,
    required String amount,
  });

  Future<void> transferToUser({
    required int recipientType,
    required String recipient,
    required String symbol,
    required String amount,
    String? remark,
  });
}

