import 'package:flutter/material.dart';

/// 汇率显示组件
class ExchangeRateDisplay extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final String rate;
  final bool isLoading;

  const ExchangeRateDisplay({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '1 $fromCurrency = $rate $toCurrency',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          if (isLoading) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
