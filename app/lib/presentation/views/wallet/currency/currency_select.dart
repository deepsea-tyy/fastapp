import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/utils/wallet_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 币种选择页面（用于提现）
class CurrencySelect extends StatefulWidget {
  const CurrencySelect({super.key});

  @override
  State<CurrencySelect> createState() => _CurrencySelectState();
}

class _CurrencySelectState extends State<CurrencySelect> {
  final WalletStore _walletStore = getIt<WalletStore>();
  final MarketDataStore _marketDataStore = getIt<MarketDataStore>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final balances = _walletStore.accountBalance?.getBalancesByType(WalletType.SPOT);
            final filteredBalances = balances?.where((balance) {
              if (_searchQuery.isEmpty) return true;
              final currency = _marketDataStore.getCurrency(balance.symbol);
              final symbolMatch = balance.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
              final nameMatch = currency?.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
              return symbolMatch || nameMatch;
            }).toList() ?? [];

            return Column(
              children: [
                // 返回按钮和标题
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: textTheme.primary),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      Text(
                        '选择币种',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 搜索栏和取消按钮
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundTheme.input,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: false,
                            decoration: InputDecoration(
                              hintText: '搜索币种/币对/合约',
                              hintStyle: TextStyle(color: textTheme.hint),
                              prefixIcon: Icon(Icons.search, color: textTheme.hint),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _isSearching = value.isNotEmpty;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_isSearching) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _isSearching = false;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('取消'),
                        ),
                      ],
                    ],
                  ),
                ),
                // 标题和排序
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '币种列表',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textTheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.sort, color: textTheme.secondary),
                        onPressed: () {
                          // TODO: 排序功能
                        },
                      ),
                    ],
                  ),
                ),
                // 币种列表
                Expanded(
                  child: filteredBalances.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty ? '暂无资产' : '未找到匹配的币种',
                            style: TextStyle(
                              fontSize: 14,
                              color: textTheme.secondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filteredBalances.length,
                          itemBuilder: (context, index) {
                            final balance = filteredBalances[index];
                            final currency = _marketDataStore.getCurrency(balance.symbol);
                            return _buildCurrencyItem(balance, currency);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(Balance balance, dynamic currency) {
    final symbol = balance.symbol;
    final currencyName = currency?.name ?? symbol;
    final logoUrl = ImageUtils.formatSingleImagePath(currency?.logo);
    final textTheme = context.textTheme;
    final borderTheme = context.borderTheme;

    return InkWell(
      onTap: () => WalletNavigator.toWithdraw(
        context,
        symbol: symbol,
        name: currencyName,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderTheme.defaultColor)),
        ),
        child: Row(
          children: [
            _buildIcon(symbol, logoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyName,
                    style: TextStyle(fontSize: 12, color: textTheme.secondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance.available.toStringAsFixed(8),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '可用',
                  style: TextStyle(fontSize: 12, color: textTheme.secondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String symbol, String? logoUrl) {
    final backgroundTheme = context.backgroundTheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundTheme.input,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl != null
          ? Image.network(
              logoUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildIconText(symbol),
            )
          : _buildIconText(symbol),
    );
  }

  Widget _buildIconText(String symbol) {
    return Center(
      child: Text(
        symbol.isNotEmpty ? symbol[0] : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
