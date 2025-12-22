import 'package:fastapp/constants/exchange_rate.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:flutter/material.dart';

/// 市场列表项组件
class MarketListItem extends StatelessWidget {
  final TickerData ticker;
  final String? logoUrl;
  final String? fullName;
  final VoidCallback? onTap;

  const MarketListItem({
    super.key,
    required this.ticker,
    this.logoUrl,
    this.fullName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastPrice = ticker.lastPrice;
    final changePercent = ticker.changePercent;
    
    // 确保价格有效（如果无效，使用默认值显示）
    final validPrice = (lastPrice.isNaN || lastPrice.isInfinite || lastPrice <= 0) 
        ? 0.0 
        : lastPrice;
    
    final isPositive = changePercent >= 0;
    final parts = ticker.symbol.split('/');
    final baseCurrency = parts.isNotEmpty ? parts[0] : ticker.symbol;
    
    // 计算人民币价格
    final cnyPrice = validPrice * ExchangeRate.getUsdToCnySync();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
        ),
        child: Row(
          children: [
            // 左侧：Logo和名称
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: logoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(baseCurrency),
                            ),
                          )
                        : _buildPlaceholderIcon(baseCurrency),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          baseCurrency,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2),
                        ),
                        if (fullName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              fullName!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatPrice(validPrice),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('¥${_formatCNYPrice(cnyPrice)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.2)),
                  ),
                ],
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(String baseCurrency) {
    return Center(
      child: Text(
        baseCurrency.isNotEmpty ? baseCurrency.substring(0, 1) : '?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
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

  String _formatCNYPrice(double price) {
    if (price.isNaN || price.isInfinite) return '0.00';
    
    if (price >= 1000) {
      final parts = price.toStringAsFixed(2).split('.');
      final integerPart = parts.isNotEmpty ? parts[0] : '0';
      final decimalPart = parts.length > 1 ? parts[1] : '';
      final formattedInteger = _addThousandSeparator(integerPart);
      return decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else {
      return price.toStringAsFixed(4);
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
