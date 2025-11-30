import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/search/search_screen.dart';
import 'package:fastapp/utils/routes/routes.dart';

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
          Icons.menu,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onMenuPressed ?? () {
          Scaffold.of(context).openEndDrawer();
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
            right: 4,
            top: 4,
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
