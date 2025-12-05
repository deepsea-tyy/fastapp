import 'package:flutter/material.dart';

/// 货币选择器组件
class CurrencySelector extends StatelessWidget {
  final String currency;
  final bool isPrimary;
  final VoidCallback? onTap;

  const CurrencySelector({
    super.key,
    required this.currency,
    this.isPrimary = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCurrencyIcon(),
          const SizedBox(width: 8),
          Text(
            currency,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, color: Colors.grey.shade700, size: 24),
        ],
      ),
    );
  }

  Widget _buildCurrencyIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue.shade400 : Colors.teal.shade400,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          isPrimary ? 'T' : '\$',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
