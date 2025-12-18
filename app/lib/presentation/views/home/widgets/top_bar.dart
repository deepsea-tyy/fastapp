import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/search_screen.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final int unreadMessageCount; // 未读消息数

  const TopBar({
    super.key,
    this.onMenuPressed,
    this.unreadMessageCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.person_outline,
          color: colorScheme.onSurface,
        ),
        onPressed: () {
          _handleUserIconTap(context);
        },
      ),
      title: _buildSearchBar(context),
      actions: [
        _buildNotificationIcon(context),
        _buildHeadphonesIcon(context),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            // 火焰图标
            Icon(
              Icons.local_fire_department,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            // MBL 文字
            Text(
              'MBL',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            // 搜索图标
            Icon(
              Icons.search,
              size: 18,
              color: theme.hintColor,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.message);
      },
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.message);
            },
          ),
          if (unreadMessageCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    unreadMessageCount > 99 ? '99+' : '$unreadMessageCount',
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeadphonesIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        Icons.headphones_outlined,
        color: colorScheme.onSurface,
      ),
      onPressed: () {
        // TODO: 打开音频支持
      },
    );
  }

  /// 处理用户图标点击事件
  void _handleUserIconTap(BuildContext context) {
    final userStore = getIt<UserStore>();
    
    // 判断登录状态
    if (userStore.isLoggedIn) {
      // 已登录，执行回调或打开侧边栏
      if (onMenuPressed != null) {
        onMenuPressed!();
      } else {
        Scaffold.of(context).openEndDrawer();
      }
    } else {
      // 未登录，跳转到登录页
      Navigator.of(context).pushNamed(Routes.login);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
