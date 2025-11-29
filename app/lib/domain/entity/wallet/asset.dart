import 'balance.dart';

/// 资产实体（包含所有余额）
class Asset {
  /// 总资产（USDT等值）
  final double totalAsset;
  
  /// 可用资产
  final double availableAsset;
  
  /// 冻结资产
  final double frozenAsset;
  
  /// 各币种余额列表
  final List<Balance> balances;
  
  /// 更新时间戳
  final int timestamp;

  Asset({
    required this.totalAsset,
    required this.availableAsset,
    required this.frozenAsset,
    required this.balances,
    required this.timestamp,
  });

  /// 从JSON创建
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      totalAsset: (json['totalAsset'] as num).toDouble(),
      availableAsset: (json['availableAsset'] as num).toDouble(),
      frozenAsset: (json['frozenAsset'] as num).toDouble(),
      balances: (json['balances'] as List<dynamic>)
          .map((item) => Balance.fromJson(item as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'totalAsset': totalAsset,
      'availableAsset': availableAsset,
      'frozenAsset': frozenAsset,
      'balances': balances.map((item) => item.toJson()).toList(),
      'timestamp': timestamp,
    };
  }

  /// 根据币种获取余额
  Balance? getBalanceByCurrency(String currency) {
    try {
      return balances.firstWhere((b) => b.currency == currency);
    } catch (e) {
      return null;
    }
  }
}

