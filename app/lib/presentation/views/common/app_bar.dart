import 'package:flutter/material.dart';

/// 通用 AppBar 组件
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.titleWidget,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: titleWidget ??
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

