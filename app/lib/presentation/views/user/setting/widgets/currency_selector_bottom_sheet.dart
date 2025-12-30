import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:fastapp/presentation/store/app/exchange_rate_store.dart';
import 'package:flutter/material.dart';

/// 币种选择底部弹窗
class CurrencySelectorBottomSheet extends StatelessWidget {
  final String currentCurrency;
  final List<Map<String, String>> currencies;
  final Function(String) onCurrencySelected;
  final ExchangeRateStore? exchangeRateStore;

  const CurrencySelectorBottomSheet({
    super.key,
    required this.currentCurrency,
    required this.currencies,
    required this.onCurrencySelected,
    this.exchangeRateStore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          buildDragHandle(),
          const SizedBox(height: 16),
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '选择币种',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 币种列表
          Expanded(
            child: _buildCurrencyList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        final currency = currencies[index];
        return _buildCurrencyItem(context, currency);
      },
    );
  }

  Widget _buildCurrencyItem(BuildContext context, Map<String, String> currency) {
    final code = currency['code']!;
    final name = currency['name']!;
    final isSelected = currentCurrency == code;
    final rate = exchangeRateStore != null ? _getExchangeRate(code) : '';

    return InkWell(
      onTap: () {
        onCurrencySelected(code);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 币种信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // 汇率显示
            if (rate.isNotEmpty) ...[
              Text(
                rate,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
            ],
            // 选中标记
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// 获取汇率字符串
  String _getExchangeRate(String code) {
    if (exchangeRateStore == null) return '';

    switch (code) {
      case 'USD':
        return '1.00';
      case 'CNY':
        return exchangeRateStore!.cny.toStringAsFixed(2);
      case 'EUR':
        return exchangeRateStore!.eur.toStringAsFixed(4);
      case 'JPY':
        return exchangeRateStore!.jpy.toStringAsFixed(2);
      case 'KRW':
        return exchangeRateStore!.krw.toStringAsFixed(2);
      default:
        return '';
    }
  }
}
