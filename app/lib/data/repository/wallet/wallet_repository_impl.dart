import '../../network/apis/wallet/wallet_api.dart';
import '../../../domain/entity/wallet/account_balance.dart';
import '../../../domain/entity/wallet/asset.dart';
import '../../../domain/entity/wallet/balance.dart';
import '../../../domain/entity/wallet/balance_log.dart';
import '../../../domain/entity/wallet/transaction.dart';
import '../../../domain/repository/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletApi _walletApi;

  WalletRepositoryImpl(this._walletApi);

  @override
  Future<AccountBalance> getAccountBalance() => _walletApi.getAccountBalance();

  @override
  Future<Asset> getAsset() => _walletApi.getAsset();

  @override
  Future<Balance?> getBalanceByCurrency(String currency) =>
      _walletApi.getBalanceByCurrency(currency);

  @override
  Future<List<Transaction>> getTransactions({
    String? currency,
    TransactionType? type,
    int? startTime,
    int? endTime,
    int? limit,
  }) =>
      _walletApi.getTransactions(
        currency: currency,
        type: type,
        startTime: startTime,
        endTime: endTime,
        limit: limit,
      );

  @override
  Future<Transaction?> getTransactionById(String transactionId) =>
      _walletApi.getTransactionById(transactionId);

  @override
  Future<List<BalanceLog>> getBalanceLogs({
    String? walletType,
    String? symbol,
    String? changeType,
    int? startTime,
    int? endTime,
    int page = 1,
    int pageSize = 20,
  }) =>
      _walletApi.getBalanceLogs(
        walletType: walletType,
        symbol: symbol,
        changeType: changeType,
        startTime: startTime,
        endTime: endTime,
        page: page,
        pageSize: pageSize,
      );

  @override
  Future<void> transfer({
    required String fromWalletType,
    required String toWalletType,
    required String symbol,
    required String amount,
  }) =>
      _walletApi.transfer(
        fromWalletType: fromWalletType,
        toWalletType: toWalletType,
        symbol: symbol,
        amount: amount,
      );

  @override
  Future<void> transferToUser({
    required int recipientType,
    required String recipient,
    required String symbol,
    required String amount,
    String? remark,
  }) =>
      _walletApi.transferToUser(
        recipientType: recipientType,
        recipient: recipient,
        symbol: symbol,
        amount: amount,
        remark: remark,
      );
}

