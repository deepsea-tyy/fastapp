import 'dart:async';
import '../../../../core/data/network/dio/dio_client.dart';
import '../../../../domain/entity/wallet/account_balance.dart';
import '../../../../domain/entity/wallet/asset.dart';
import '../../../../domain/entity/wallet/balance.dart';
import '../../../../domain/entity/wallet/balance_log.dart';
import '../../../../domain/entity/wallet/transaction.dart';
import '../../constants/endpoints.dart';

/// 钱包API
class WalletApi {
  final DioClient _dioClient;

  WalletApi(this._dioClient);

  Future<AccountBalance> getAccountBalance() async {
    final response = await _dioClient.dio.get(Endpoints.walletBalance);
    return AccountBalance.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Asset> getAsset() async {
    final accountBalance = await getAccountBalance();
    final allBalances = accountBalance.getAllBalances();

    final totalStats = allBalances.fold<Map<String, double>>(
      {'available': 0.0, 'frozen': 0.0, 'total': 0.0},
      (stats, balance) => {
        'available': stats['available']! + balance.available,
        'frozen': stats['frozen']! + balance.frozen,
        'total': stats['total']! + balance.total,
      },
    );

    return Asset(
      totalAsset: totalStats['total']!,
      availableAsset: totalStats['available']!,
      frozenAsset: totalStats['frozen']!,
      balances: allBalances,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<Balance?> getBalanceByCurrency(String currency) async {
    final asset = await getAsset();
    return asset.getBalanceByCurrency(currency);
  }

  Future<List<Transaction>> getTransactions({
    String? currency,
    TransactionType? type,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.walletBalanceLog,
      queryParameters: {
        if (currency != null) 'symbol': currency,
        if (type != null) 'change_type': type.name,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (limit != null) 'limit': limit,
      },
    );

    final list = (response.data as Map<String, dynamic>)['list'] as List?;
    return list
            ?.map((item) => Transaction.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<Transaction?> getTransactionById(String transactionId) =>
      Future.value(null);

  Future<List<BalanceLog>> getBalanceLogs({
    String? walletType,
    String? symbol,
    String? changeType,
    int? startTime,
    int? endTime,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.walletBalanceLog,
      queryParameters: {
        if (walletType != null) 'wallet_type': walletType,
        if (symbol != null) 'symbol': symbol,
        if (changeType != null) 'change_type': changeType,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        'page': page,
        'page_size': pageSize,
      },
    );

    final list = (response.data as Map<String, dynamic>)['list'] as List?;
    return list
            ?.map((item) => BalanceLog.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<void> transfer({
    required String fromWalletType,
    required String toWalletType,
    required String symbol,
    required String amount,
  }) async {
    await _dioClient.dio.post(
      Endpoints.walletTransfer,
      data: {
        'fromWalletType': fromWalletType,
        'toWalletType': toWalletType,
        'symbol': symbol,
        'amount': amount,
      },
    );
  }

  Future<void> transferToUser({
    required int recipientType,
    required String recipient,
    required String symbol,
    required String amount,
    String? remark,
  }) async {
    await _dioClient.dio.post(
      Endpoints.walletTransferToUser,
      data: {
        'recipient_type': recipientType,
        'recipient': recipient,
        'symbol': symbol,
        'amount': amount,
        if (remark != null && remark.isNotEmpty) 'remark': remark,
      },
    );
  }
}

