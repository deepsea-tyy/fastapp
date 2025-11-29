import 'package:flutter/material.dart';

class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '值得您信赖的平台',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '安全无小事，为了保护您的资产与信息安全，我们进无止境',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 24),
          _buildTrustCard(
            context,
            title: '用户保护基金',
            description: '我们价值 \$5.99 亿 的用户保护基金，为您的资产安全增加一份保障',
            icon: Icons.security,
          ),
          const SizedBox(height: 12),
          _buildTrustCard(
            context,
            title: '储备金证明',
            description: '我们承诺，Bitget 以至少1:1的比例持有所有用户资产',
            icon: Icons.verified,
          ),
          const SizedBox(height: 12),
          _buildTrustCard(
            context,
            title: '安全冷存储',
            description: '我们将大部分加密资产安全存放于离线的多签钱包中',
            icon: Icons.lock,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

