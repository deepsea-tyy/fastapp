import 'package:flutter/material.dart';
import 'package:fastapp/domain/entity/feed/feed_post.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/views/feed/feed_profile.dart';
import 'package:fastapp/presentation/views/feed/content_management_page.dart';
import 'post_edit_page.dart';
import 'article_edit_page.dart';

/// 创建内容菜单组件
///
/// 显示帖子、文章、视频三个创建选项
class CreatePostMenu extends StatelessWidget {
  final Function(FeedPost)? onPostCreated;

  const CreatePostMenu({super.key, this.onPostCreated});

  static void show(BuildContext context, {Function(FeedPost)? onPostCreated}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostMenu(onPostCreated: onPostCreated),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.edit_outlined,
                label: '帖子',
                bgColor: colorScheme.primary.withAlpha(26),
                iconColor: colorScheme.primary,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PostEditPage(type: 1),
                    ),
                  );
                  if (result is FeedPost && onPostCreated != null) {
                    onPostCreated!(result);
                  }
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.article_outlined,
                label: '文章',
                bgColor: colorScheme.primary.withAlpha(26),
                iconColor: colorScheme.primary,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ArticleEditPage(type: 2),
                    ),
                  );
                  if (result is FeedPost && onPostCreated != null) {
                    onPostCreated!(result);
                  }
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.video_library_outlined,
                label: '视频',
                bgColor: colorScheme.primary.withAlpha(26),
                iconColor: colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 跳转到创建视频页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('创建视频功能开发中')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 导航区域
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                label: '个人主页',
                onTap: () {
                  Navigator.pop(context);
                  final userStore = getIt<UserStore>();
                  final userId = userStore.currentUser?.id;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(userId: userId??0),
                    ),
                  );
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.manage_accounts_outlined,
                label: '内容管理',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ContentManagementPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 36,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
