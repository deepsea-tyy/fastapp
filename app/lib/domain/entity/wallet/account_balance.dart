import 'balance.dart';

/// 钱包账户类型
enum WalletType {
  FUNDING,
  SPOT,
  FUTURES,
  MARGIN,
  EARN,
  OPTIONS;

  static WalletType fromString(String value) {
    return WalletType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WalletType.FUNDING,
    );
  }
}

/// 账户余额实体
class AccountBalance {
  final Map<WalletType, List<Balance>> balances;

  AccountBalance({required this.balances});

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    final balances = <WalletType, List<Balance>>{};

    json.forEach((key, value) {
      if (value is List) {
        balances[WalletType.fromString(key)] = value
            .map((item) => Balance.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    });

    return AccountBalance(balances: balances);
  }

  List<Balance> getBalancesByType(WalletType type) => balances[type] ?? [];

  Balance? getBalance(WalletType type, String symbol) {
    try {
      return balances[type]?.firstWhere((b) => b.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  List<Balance> getAllBalances() =>
      balances.values.expand((list) => list).toList();
}
