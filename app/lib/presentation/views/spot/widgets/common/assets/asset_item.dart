import 'package:fastapp/utils/image_utils.dart';
import 'package:flutter/material.dart';

/// 资产项组件
class AssetItem extends StatelessWidget {
  final String symbol;
  final String name;
  final Color iconColor;
  final String iconText;
  final String balance;
  final String? logoUrl;

  const AssetItem({
    super.key,
    required this.symbol,
    required this.name,
    required this.iconColor,
    required this.iconText,
    required this.balance,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          balance,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    final formattedLogoUrl = logoUrl != null ? ImageUtils.formatSingleImagePath(logoUrl!) : null;
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: formattedLogoUrl != null && formattedLogoUrl != ImageUtils.defaultImage
          ? Image.network(
              formattedLogoUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDefaultIcon(),
            )
          : _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      decoration: BoxDecoration(
        color: iconColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          iconText,
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
