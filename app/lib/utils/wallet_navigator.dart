import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/wallet/currency/deposit_screen.dart';
import 'package:fastapp/presentation/views/wallet/currency/withdraw_screen.dart';
import 'package:fastapp/presentation/views/wallet/currency/transfer_screen.dart';
import 'package:fastapp/presentation/views/wallet/currency/transfer_to_user_screen.dart';
import 'package:fastapp/presentation/views/wallet/currency/currency_list.dart';
import 'package:fastapp/presentation/views/wallet/currency/currency_select.dart';

/// 钱包相关页面导航工具类
class WalletNavigator {
  /// 跳转到充值页面
  ///
  /// [context] - 当前上下文
  /// [symbol] - 币种符号（必填）
  /// [name] - 币种名称（选填）
  static Future<void> toDeposit(
    BuildContext context, {
    required String symbol,
    String? name,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DepositScreen(
          symbol: symbol,
          name: name ?? symbol,
        ),
      ),
    );
  }

  /// 跳转到提现页面
  ///
  /// [context] - 当前上下文
  /// [symbol] - 币种符号（必填）
  /// [name] - 币种名称（选填）
  static Future<void> toWithdraw(
    BuildContext context, {
    required String symbol,
    String? name,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WithdrawScreen(
          symbol: symbol,
          name: name ?? symbol,
        ),
      ),
    );
  }

  /// 跳转到币种选择页面（用于充值）
  ///
  /// [context] - 当前上下文
  static Future<void> toCurrencyListForDeposit(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CurrencyList(),
      ),
    );
  }

  /// 跳转到币种选择页面（用于提现）
  ///
  /// [context] - 当前上下文
  static Future<void> toCurrencySelectForWithdraw(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CurrencySelect(),
      ),
    );
  }

  /// 跳转到划转页面
  ///
  /// [context] - 当前上下文
  static Future<void> toTransfer(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TransferScreen(),
      ),
    );
  }

  /// 跳转到用户转账页面
  ///
  /// [context] - 当前上下文
  static Future<void> toTransferToUser(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TransferToUserScreen(),
      ),
    );
  }
}
