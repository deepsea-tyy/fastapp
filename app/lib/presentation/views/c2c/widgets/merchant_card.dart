import 'package:fastapp/presentation/views/c2c/c2c_order_screen.dart';
import 'package:flutter/material.dart';

/// 商家卡片组件
class MerchantCard extends StatelessWidget {
  final Map<String, dynamic> merchant;
  final String currency;
  final String fiatCurrency;
  final bool isBuying;

  const MerchantCard({
    super.key,
    required this.merchant,
    required this.currency,
    required this.fiatCurrency,
    required this.isBuying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMerchantHeader(),
          const SizedBox(height: 12),
          _buildTradeStats(),
          const SizedBox(height: 16),
          _buildPriceSection(),
          const SizedBox(height: 12),
          _buildLimitAndAvailable(),
          const SizedBox(height: 12),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildMerchantHeader() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        // Name and badges
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  merchant['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ..._buildBadges(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBadges() {
    final badges = merchant['badges'] as List<dynamic>? ?? [];
    return badges.map((badge) {
      if (badge == 'gold') {
        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFF5C842),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified, color: Colors.white, size: 16),
        );
      } else if (badge == 'purple') {
        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF9C27B0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified, color: Colors.white, size: 16),
        );
      } else if (badge == 'shield') {
        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFF5C842),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.security, color: Colors.white, size: 16),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  Widget _buildTradeStats() {
    return Row(
      children: [
        Text(
          '交易: ${merchant['orders']} 订单 (${merchant['completionRate'].toStringAsFixed(2)}%)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '¥ ',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          merchant['price'].toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '/$currency',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitAndAvailable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '限额 ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${_formatAmount(merchant['minAmount'])} - ${_formatAmount(merchant['maxAmount'])} $fiatCurrency',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '可用 ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${_formatAmount(merchant['available'])} $currency',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Builder(
      builder: (context) => Row(
        children: [
          // Verification badge
          if (merchant['verified'] == true)
            Row(
              children: [
                Icon(Icons.image_outlined, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '需要验证',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          const Spacer(),
          // Payment methods and time
          Row(
            children: [
              ..._buildPaymentBadges(),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                merchant['timeLimit'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Buy/Sell button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => C2COrderScreen(
                    merchant: merchant,
                    currency: currency,
                    fiatCurrency: fiatCurrency,
                    isBuying: isBuying,
                    price: (merchant['price'] as num).toDouble(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              isBuying ? '买入' : '卖出',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentBadges() {
    final methods = merchant['paymentMethods'] as List<dynamic>? ?? [];
    return methods.map<Widget>((method) {
      return Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              method,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 4,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C842),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatAmount(dynamic amount) {
    if (amount is int) {
      return amount.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } else if (amount is double) {
      return amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return amount.toString();
  }
}
