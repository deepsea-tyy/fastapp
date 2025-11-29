import 'dart:async';

import '../entity/wallet/asset.dart';
import '../entity/wallet/balance.dart';
import '../entity/wallet/transaction.dart';

/// 资产仓库接口
abstract class WalletRepository {
  /// 获取资产信息
  Future<Asset> getAsset();

  /// 根据币种获取余额
  Future<Balance?> getBalanceByCurrency(String currency);

  /// 获取交易记录列表
  /// [currency] 币种（可选）
  /// [type] 交易类型（可选）
  /// [startTime] 开始时间戳（可选）
  /// [endTime] 结束时间戳（可选）
  /// [limit] 返回数量限制（可选）
  Future<List<Transaction>> getTransactions({
    String? currency,
    TransactionType? type,
    int? startTime,
    int? endTime,
    int? limit,
  });

  /// 根据ID获取交易记录
  Future<Transaction?> getTransactionById(String transactionId);
}

