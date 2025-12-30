import 'package:fastapp/presentation/views/wallet/widgets/common/unified_assets_card.dart';
import 'package:flutter/material.dart';

/// 预估总资产卡片（总览）
class OverviewAssets extends StatelessWidget {
  const OverviewAssets({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedAssetsCard(isOverviewMode: true);
  }
}
