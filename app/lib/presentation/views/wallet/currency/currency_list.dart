import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/currency.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/utils/wallet_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 币种列表页面（用于充值）
class CurrencyList extends StatefulWidget {
  const CurrencyList({super.key});

  @override
  State<CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  final MarketDataStore _marketDataStore = getIt<MarketDataStore>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Scaffold(
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final allCurrencies = _marketDataStore.allCurrencies;

            final filteredCurrencies = allCurrencies.where((currency) {
              if (_searchQuery.isEmpty) return true;
              final symbolMatch = currency.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
              final nameMatch = currency.name.toLowerCase().contains(_searchQuery.toLowerCase());
              return symbolMatch || nameMatch;
            }).toList();

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
                // 搜索栏
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundTheme.input,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索币种',
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
                        });
                      },
                    ),
                  ),
                ),
                // 币种列表
                Expanded(
                  child: filteredCurrencies.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty ? '暂无币种' : '未找到匹配的币种',
                            style: TextStyle(
                              fontSize: 14,
                              color: textTheme.secondary,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                '币种',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textTheme.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: filteredCurrencies.length,
                                itemBuilder: (context, index) {
                                  final currency = filteredCurrencies[index];
                                  return _buildCurrencyItem(currency);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(Currency currency) {
    final symbol = currency.symbol;
    final currencyName = currency.name;
    final logoUrl = ImageUtils.formatSingleImagePath(currency.logo);
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;
    final borderTheme = context.borderTheme;

    return InkWell(
      onTap: () => WalletNavigator.toDeposit(
        context,
        symbol: symbol,
        name: currencyName,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderTheme.defaultColor),
          ),
        ),
        child: Row(
          children: [
            Container(
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
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          symbol.isNotEmpty ? symbol[0] : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        symbol.isNotEmpty ? symbol[0] : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: textTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
