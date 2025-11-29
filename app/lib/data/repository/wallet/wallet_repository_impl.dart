import 'dart:async';
import '../../network/apis/wallet/wallet_api.dart';
import '../../../domain/entity/wallet/asset.dart';
import '../../../domain/entity/wallet/balance.dart';
import '../../../domain/entity/wallet/transaction.dart';
import '../../../domain/repository/wallet_repository.dart';

/// 资产仓库实现
class WalletRepositoryImpl implements WalletRepository {
  final WalletApi _walletApi;

  WalletRepositoryImpl(this._walletApi);

  @override
  Future<Asset> getAsset() async {
    try {
      return await _walletApi.getAsset();
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Balance?> getBalanceByCurrency(String currency) async {
    try {
      return await _walletApi.getBalanceByCurrency(currency);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Transaction>> getTransactions({
    String? currency,
    TransactionType? type,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    try {
      return await _walletApi.getTransactions(
        currency: currency,
        type: type,
        startTime: startTime,
        endTime: endTime,
        limit: limit,
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Transaction?> getTransactionById(String transactionId) async {
    try {
      return await _walletApi.getTransactionById(transactionId);
    } catch (e) {
      throw e;
    }
  }
}

