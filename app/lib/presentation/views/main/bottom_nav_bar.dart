import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<HomeStore>();
    final theme = Theme.of(context);

    return Observer(
      builder: (_) => BottomNavigationBar(
        currentIndex: store.bottomNavIndex,
        onTap: (index) {
          store.setBottomNavIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '行情',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: '交易',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: '合约',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '资产',
          ),
        ],
      ),
    );
  }
}
