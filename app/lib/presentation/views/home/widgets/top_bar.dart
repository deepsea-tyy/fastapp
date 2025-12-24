import 'package:flutter/material.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/constants/app_backgrounds.dart';
import 'package:fastapp/utils/icon_mapper.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final int unreadMessageCount; // 未读消息数

  // 搜索框配置
  final String? searchIconName; // Web 端图标名称，如 'material-symbols:local-fire-department'
  final String? searchKeyword; // 搜索关键词文本，如 'MBL'
  final Color? searchIconColor; // 图标颜色，如果为 null 则使用配置的默认颜色
  final String? searchRoute; // 点击搜索框跳转的路由，默认为 homeSearch

  const TopBar({
    super.key,
    this.onMenuPressed,
    this.unreadMessageCount = 0,
    this.searchIconName,
    this.searchKeyword,
    this.searchIconColor,
    this.searchRoute,
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
    final backgrounds = AppBackgrounds.of(context);

    // 获取图标和颜色配置，如果没有配置则使用默认值
    final iconData = searchIconName != null
        ? IconMapper.getIcon(searchIconName)
        : Icons.local_fire_department;

    final iconColor = searchIconColor ??
        (searchIconName != null
            ? IconMapper.getColor(searchIconName)
            : colorScheme.primary);

    final keyword = searchKeyword ?? 'MBL';

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(searchRoute ?? Routes.homeSearch);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: backgrounds.input,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            // 可配置的图标
            Icon(
              iconData,
              size: 18,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            // 可配置的文字
            Text(
              keyword,
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pushNamed(Routes.message),
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

  void _handleUserIconTap(BuildContext context) {
    final userStore = getIt<UserStore>();

    if (!userStore.isLoggedIn) {
      Navigator.of(context).pushNamed(Routes.login);
      return;
    }

    if (onMenuPressed != null) {
      onMenuPressed!();
    } else {
      Scaffold.of(context).openEndDrawer();
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
