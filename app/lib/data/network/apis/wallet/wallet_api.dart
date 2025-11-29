import 'dart:async';
import '../../../mock/mock_wallet_data.dart';
import '../../../../domain/entity/wallet/asset.dart';
import '../../../../domain/entity/wallet/balance.dart';
import '../../../../domain/entity/wallet/transaction.dart';

/// 资产API实现（使用模拟数据）
class WalletApi {
  /// 模拟延迟
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// 获取资产信息
  Future<Asset> getAsset() async {
    await _simulateDelay();
    return MockWalletData.generateAsset();
  }

  /// 根据币种获取余额
  Future<Balance?> getBalanceByCurrency(String currency) async {
    await _simulateDelay();
    final asset = MockWalletData.generateAsset();
    return asset.getBalanceByCurrency(currency);
  }

  /// 获取交易记录列表
  Future<List<Transaction>> getTransactions({
    String? currency,
    TransactionType? type,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    await _simulateDelay();
    return MockWalletData.generateTransactions(
      currency: currency,
      type: type,
      limit: limit,
    );
  }

  /// 根据ID获取交易记录
  Future<Transaction?> getTransactionById(String transactionId) async {
    await _simulateDelay();
    return MockWalletData.generateTransactionById(transactionId);
  }
}

