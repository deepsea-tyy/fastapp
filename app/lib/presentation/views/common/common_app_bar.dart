import 'package:flutter/material.dart';

/// 通用 AppBar 组件
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;
  final bool showMenuButton;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.titleWidget,
    this.bottom,
    this.showMenuButton = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> finalActions = [];

    // 如果显示菜单按钮，添加到 actions 最前面
    if (showMenuButton) {
      finalActions.add(
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            if (scaffoldKey?.currentState != null) {
              scaffoldKey!.currentState!.openEndDrawer();
            } else {
              Scaffold.of(context).openEndDrawer();
            }
          },
          tooltip: '菜单',
        ),
      );
    }

    // 添加其他 actions
    if (actions != null) {
      finalActions.addAll(actions!);
    }

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
      actions: finalActions.isEmpty ? null : finalActions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
