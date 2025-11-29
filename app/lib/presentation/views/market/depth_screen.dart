import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/market/depth_store.dart';
import 'package:fastapp/presentation/views/market/widgets/depth_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 深度图独立页面
class DepthScreen extends StatefulWidget {
  const DepthScreen({super.key});

  @override
  State<DepthScreen> createState() => _DepthScreenState();
}

class _DepthScreenState extends State<DepthScreen> {
  final DepthStore _store = getIt<DepthStore>();

  @override
  void initState() {
    super.initState();
    _store.loadDepthData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Observer(
          builder: (_) => Text(
            '${_store.currentSymbol} 深度图',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _store.refreshDepthData(),
            tooltip: '刷新',
          ),
        ],
      ),
      body: const DepthChart(),
    );
  }
}

