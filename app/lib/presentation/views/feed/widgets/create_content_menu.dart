import 'package:flutter/material.dart';
import 'post_edit_page.dart';
import 'article_edit_page.dart';

/// 创建内容菜单组件
///
/// 显示帖子、文章、视频三个创建选项
class CreatePostMenu extends StatelessWidget {
  const CreatePostMenu({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostMenu(),
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
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PostEditPage(type: 1),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.article_outlined,
                label: '文章',
                bgColor: colorScheme.primary.withAlpha(26),
                iconColor: colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ArticleEditPage(type: 2),
                    ),
                  );
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
}
