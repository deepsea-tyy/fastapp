import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/store/search/search_store.dart';
import 'package:fastapp/constants/app_backgrounds.dart';
import 'package:fastapp/utils/icon_mapper.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final int unreadMessageCount; // 未读消息数
  final VoidCallback? onUnreadMessageTap;

  // 搜索框配置
  final String? searchIconName;
  final String? searchKeyword;
  final Color? searchIconColor;
  final String? searchRoute;

  const TopBar({
    super.key,
    this.onMenuPressed,
    this.unreadMessageCount = 0,
    this.onUnreadMessageTap,
    this.searchIconName,
    this.searchKeyword,
    this.searchIconColor,
    this.searchRoute,
  });

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  late final SearchStore _searchStore;

  @override
  void initState() {
    super.initState();
    _searchStore = getIt<SearchStore>();
    _searchStore.autoRefresh();
  }

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
    final backgrounds = AppBackgrounds.of(context);

    return Observer(
      builder: (_) {
        final topKeyword = _searchStore.topHotKeyword;
        final keyword = widget.searchKeyword ?? topKeyword?.keyword;
        final iconName = widget.searchIconName ?? topKeyword?.icon;
        final hasCustomIcon = iconName?.isNotEmpty ?? false;

        final displayText = keyword?.isNotEmpty == true ? keyword! : '搜索';
        final displayIcon = hasCustomIcon ? IconMapper.getIcon(iconName) : Icons.search;
        final displayColor = hasCustomIcon
            ? (widget.searchIconColor ??
                IconMapper.parseColor(topKeyword?.color) ??
                IconMapper.getColor(iconName))
            : theme.hintColor;

        return InkWell(
          onTap: () => Navigator.of(context).pushNamed(widget.searchRoute ?? Routes.homeSearch),
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
                Icon(displayIcon, size: 18, color: displayColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(color: theme.hintColor, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        );
      },
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
          onPressed: () {
            widget.onUnreadMessageTap?.call();
            Navigator.of(context).pushNamed(Routes.message);
          },
        ),
        if (widget.unreadMessageCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () {
                widget.onUnreadMessageTap?.call();
                Navigator.of(context).pushNamed(Routes.message);
              },
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
                    widget.unreadMessageCount > 99
                        ? '99+'
                        : '${widget.unreadMessageCount}',
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
          ),
      ],
    );
  }

  Widget _buildHeadphonesIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        Icons.headset_mic_outlined,
        color: colorScheme.onSurface,
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.customerServiceChat);
      },
    );
  }

  void _handleUserIconTap(BuildContext context) {
    final userStore = getIt<UserStore>();

    if (!userStore.isLoggedIn) {
      Navigator.of(context).pushNamed(Routes.login);
      return;
    }

    Navigator.of(context).pushNamed(Routes.userCenter);
  }
}
