import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/search_screen.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const TopBar({
    super.key,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.person_outline,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          _handleUserIconTap(context);
        },
      ),
      title: _buildSearchBar(context),
      actions: [
        _buildChatIcon(context),
        _buildHeadphonesIcon(context),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            // 火焰图标
            Icon(
              Icons.local_fire_department,
              size: 18,
              color: Colors.deepOrange,
            ),
            const SizedBox(width: 8),
            // MBL 文字
            Text(
              'MBL',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            // 搜索图标
            Icon(
              Icons.search,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildChatIcon(BuildContext context) {
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
              Icons.chat_bubble_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.message);
            },
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(7),
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 12,
              ),
              child: const Center(
                child: Text(
                  '58',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
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
    return IconButton(
      icon: Icon(
        Icons.headphones_outlined,
        color: Theme.of(context).colorScheme.onSurface,
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
