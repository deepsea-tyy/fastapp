import 'dart:math';
import '../../domain/entity/wallet/asset.dart';
import '../../domain/entity/wallet/balance.dart';
import '../../domain/entity/wallet/transaction.dart';

/// 模拟资产数据生成器
class MockWalletData {
  static final Random _random = Random();
  static int _transactionIdCounter = 2000000;

  /// 生成资产信息
  static Asset generateAsset() {
    final balances = [
      Balance(
        symbol: 'USDT',
        available: 10000.0 + _random.nextDouble() * 5000,
        frozen: _random.nextDouble() * 1000,
        total: 11000.0 + _random.nextDouble() * 6000,
        name: 'Tether',
      ),
      Balance(
        symbol: 'BTC',
        available: 0.1 + _random.nextDouble() * 0.1,
        frozen: _random.nextDouble() * 0.01,
        total: 0.1 + _random.nextDouble() * 0.11,
        name: 'Bitcoin',
        logoUrl: '',
      ),
      Balance(
        symbol: 'ETH',
        available: 1.0 + _random.nextDouble() * 2,
        frozen: _random.nextDouble() * 0.1,
        total: 1.0 + _random.nextDouble() * 2.1,
        name: 'Ethereum',
        logoUrl: '',
      ),
      Balance(
        symbol: 'SOL',
        available: 10.0 + _random.nextDouble() * 20,
        frozen: _random.nextDouble() * 2,
        total: 10.0 + _random.nextDouble() * 22,
        name: 'Solana',
        logoUrl: '',
      ),
    ];

    // 计算总资产（USDT等值，简化计算）
    final totalAsset = balances.fold<double>(
      0.0,
      (sum, balance) {
        final price = _getCurrencyPrice(balance.symbol);
        return sum + (balance.total * price);
      },
    );
    
    final availableAsset = balances.fold<double>(
      0.0,
      (sum, balance) {
        final price = _getCurrencyPrice(balance.currency);
        return sum + (balance.available * price);
      },
    );
    
    final frozenAsset = balances.fold<double>(
      0.0,
      (sum, balance) {
        final price = _getCurrencyPrice(balance.currency);
        return sum + (balance.frozen * price);
      },
    );
    
    return Asset(
      totalAsset: totalAsset,
      availableAsset: availableAsset,
      frozenAsset: frozenAsset,
      balances: balances,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 生成交易记录列表
  static List<Transaction> generateTransactions({
    String? currency,
    TransactionType? type,
    int? limit = 20,
  }) {
    final currencies = currency != null
        ? [currency]
        : ['USDT', 'BTC', 'ETH', 'SOL'];
    final types = type != null
        ? [type]
        : TransactionType.values;
    
    final List<Transaction> transactions = [];
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < (limit ?? 20); i++) {
      final txCurrency = currencies[_random.nextInt(currencies.length)];
      final txType = types[_random.nextInt(types.length)];
      final txStatus = _random.nextDouble() > 0.2
          ? TransactionStatus.success
          : _random.nextDouble() > 0.5
              ? TransactionStatus.pending
              : TransactionStatus.failed;
      
      final amount = _random.nextDouble() * 1000 + 10;
      final fee = amount * 0.001; // 0.1%手续费
      
      final createdAt = now - (_random.nextInt(30 * 24 * 60 * 60 * 1000)); // 30天内
      final completedAt = txStatus == TransactionStatus.success
          ? createdAt + _random.nextInt(60 * 60 * 1000) // 1小时内完成
          : null;
      
      transactions.add(Transaction(
        id: 'TX_${_transactionIdCounter++}',
        currency: txCurrency,
        type: txType,
        status: txStatus,
        amount: amount,
        fee: fee,
        feeCurrency: txCurrency,
        symbol: txType == TransactionType.trade
            ? '${txCurrency}/USDT'
            : null,
        createdAt: createdAt,
        completedAt: completedAt,
        txHash: txType == TransactionType.deposit || txType == TransactionType.withdrawal
            ? '0x${_random.nextInt(1000000).toRadixString(16).padLeft(64, '0')}'
            : null,
        address: txType == TransactionType.deposit || txType == TransactionType.withdrawal
            ? '0x${_random.nextInt(1000000).toRadixString(16).padLeft(40, '0')}'
            : null,
      ));
    }
    
    // 按创建时间倒序排列
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return transactions;
  }

  /// 根据ID生成交易记录
  static Transaction? generateTransactionById(String transactionId) {
    final transactions = generateTransactions(limit: 100);
    try {
      return transactions.firstWhere((tx) => tx.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  /// 获取币种价格（USDT等值）
  static double _getCurrencyPrice(String currency) {
    switch (currency.toUpperCase()) {
      case 'USDT':
        return 1.0;
      case 'BTC':
        return 90714.12;
      case 'ETH':
        return 3034.23;
      case 'SOL':
        return 137.45;
      case 'XRP':
        return 2.1733;
      case 'BGB':
        return 3.7;
      default:
        return 1.0;
    }
  }
}

