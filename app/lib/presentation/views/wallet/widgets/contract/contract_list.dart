import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// 合约列表
class ContractList extends StatelessWidget {
  const ContractList({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(text: '暂无仓位', height: 300);
  }
}
