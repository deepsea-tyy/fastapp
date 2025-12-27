import 'balance.dart';

class Asset {
  final double totalAsset;
  final double availableAsset;
  final double frozenAsset;
  final List<Balance> balances;
  final int timestamp;

  Asset({
    required this.totalAsset,
    required this.availableAsset,
    required this.frozenAsset,
    required this.balances,
    required this.timestamp,
  });

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

  Map<String, dynamic> toJson() => {
        'totalAsset': totalAsset,
        'availableAsset': availableAsset,
        'frozenAsset': frozenAsset,
        'balances': balances.map((item) => item.toJson()).toList(),
        'timestamp': timestamp,
      };

  Balance? getBalanceByCurrency(String currency) {
    try {
      return balances.firstWhere((b) => b.symbol == currency);
    } catch (_) {
      return null;
    }
  }
}

