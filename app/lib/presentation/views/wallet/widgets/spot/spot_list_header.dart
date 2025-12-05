import 'package:fastapp/presentation/views/wallet/currency/currency_list.dart';
import 'package:flutter/material.dart';

/// 现货列表头部
class SpotListHeader extends StatelessWidget {
  const SpotListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '资产',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CurrencyList(),
                ),
              );
            },
            child: Icon(
              Icons.search,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
