import 'package:flutter/material.dart';
import 'grid_container_screen.dart';

/// 网格交易页面 - 直接使用 GridContainerScreen
class GridTradingScreen extends StatelessWidget {
  const GridTradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接返回 GridContainerScreen，不需要额外导航
    return const GridContainerScreen(initialIndex: 0);
  }
}
