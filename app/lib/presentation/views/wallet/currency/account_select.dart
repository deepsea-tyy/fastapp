import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:flutter/material.dart';

/// 账户选择对话框
class AccountSelect extends StatelessWidget {
  final WalletType? currentAccount;
  final WalletType? excludeAccount; // 排除某个账户（避免选择相同的来源和目标账户）

  const AccountSelect({
    super.key,
    this.currentAccount,
    this.excludeAccount,
  });

  @override
  Widget build(BuildContext context) {
    final accounts = _getAvailableAccounts();
    final textTheme = context.textTheme;
    final borderTheme = context.borderTheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('选择账户'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          final isSelected = currentAccount == account.type;
          final isExcluded = excludeAccount == account.type;

          return InkWell(
            onTap: isExcluded ? null : () {
              Navigator.of(context).pop(account.type);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: borderTheme.defaultColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: isExcluded ? textTheme.disabled : textTheme.primary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<({String name, WalletType type})> _getAvailableAccounts() {
    return [
      (name: '资金账户', type: WalletType.FUNDING),
      (name: '现货账户', type: WalletType.SPOT),
      (name: 'U本位合约账户', type: WalletType.FUTURES),
      (name: '杠杆账户', type: WalletType.MARGIN),
      (name: '期权账户', type: WalletType.OPTIONS),
      (name: '赚币账户', type: WalletType.EARN),
    ];
  }
}
