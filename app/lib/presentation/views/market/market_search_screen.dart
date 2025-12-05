import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 市场搜索页面
class MarketSearchScreen extends StatefulWidget {
  const MarketSearchScreen({super.key});

  @override
  State<MarketSearchScreen> createState() => _MarketSearchScreenState();
}

class _MarketSearchScreenState extends State<MarketSearchScreen> {
  final MarketStore _marketStore = getIt<MarketStore>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (_marketStore.tickerList.isEmpty) {
        _marketStore.loadAllTickers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildSearchList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        hintText: '搜索币种/币对/合约',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchList() {
    return Observer(
      builder: (_) {
        if (_marketStore.isLoading && _marketStore.tickerList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        if (_marketStore.errorMessage != null && _marketStore.tickerList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
                const SizedBox(height: 16),
                Text(_marketStore.errorMessage ?? '加载失败', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          );
        }

        var tickers = List.from(_marketStore.tickerList);
        final query = _searchController.text.trim().toUpperCase();

        if (query.isNotEmpty) {
          tickers = tickers.where((ticker) {
            final symbol = ticker.symbol.toUpperCase();
            return symbol.contains(query);
          }).toList();
        }

        if (tickers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, color: Colors.grey.shade400, size: 64),
                const SizedBox(height: 16),
                Text('暂无结果', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('请尝试其他关键词', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: tickers.length,
          itemBuilder: (context, index) {
            final ticker = tickers[index];
            final parts = ticker.symbol.split('/');
            final baseCurrency = parts.isNotEmpty ? parts[0] : ticker.symbol;
            final lastPrice = ticker.lastPrice;
            final changePercent = ticker.changePercent;
            final isPositive = changePercent >= 0;

            if (lastPrice.isNaN || lastPrice.isInfinite) {
              return const SizedBox.shrink();
            }

            return InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => MarketDetailScreen(ticker: ticker)),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                baseCurrency.isNotEmpty ? baseCurrency.substring(0, 1) : '?',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      baseCurrency,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    if (parts.length > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          '/${parts[1]}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '10x',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatPrice(lastPrice),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatPrice(double price) {
    if (price.isNaN || price.isInfinite) return '0.00';
    
    if (price >= 1000) {
      final parts = price.toStringAsFixed(2).split('.');
      final integerPart = parts.isNotEmpty ? parts[0] : '0';
      final decimalPart = parts.length > 1 ? parts[1] : '';
      final formattedInteger = _addThousandSeparator(integerPart);
      return decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  String _addThousandSeparator(String number) {
    if (number.isEmpty) return '0';
    
    final reversed = number.split('').reversed.join();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 > reversed.length) ? reversed.length : i + 3;
      chunks.add(reversed.substring(i, end));
    }
    
    return chunks.join(',').split('').reversed.join();
  }
}
