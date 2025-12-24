import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeStore = getIt<HomeStore>();
    final themeStore = getIt<ThemeStore>();

    return Observer(
      builder: (_) {
        // 访问 themeStore.currentTheme 确保主题变化时重建
        final _ = themeStore.currentTheme;
        final bottomNavTheme = context.bottomNavTheme;

        return BottomNavigationBar(
          currentIndex: homeStore.bottomNavIndex,
          onTap: (index) {
            homeStore.setBottomNavIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: bottomNavTheme.background,
          selectedItemColor: bottomNavTheme.selectedItem,
          unselectedItemColor: bottomNavTheme.unselectedItem,
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
        );
      },
    );
  }
}
