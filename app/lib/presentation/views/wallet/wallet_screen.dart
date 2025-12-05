import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/widgets/contract/contract_tab.dart';
import 'package:fastapp/presentation/views/wallet/widgets/funds/funds_tab.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/overview_tab.dart';
import 'package:fastapp/presentation/views/wallet/widgets/spot/spot_tab.dart';
import 'package:flutter/material.dart';

/// 资产管理页面
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  final WalletStore _store = getIt<WalletStore>();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _store.loadAsset();
    _store.loadTransactions();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  TabController get tabController {
    _tabController ??= TabController(length: 4, vsync: this);
    return _tabController!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // TabBar 导航栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: tabController,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  tabs: const [
                    Tab(text: '总览'),
                    Tab(text: '合约'),
                    Tab(text: '现货'),
                    Tab(text: '资金'),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),
            // TabBarView 内容区域
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [
                  OverviewTab(),
                  ContractTab(),
                  SpotTab(),
                  FundsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
