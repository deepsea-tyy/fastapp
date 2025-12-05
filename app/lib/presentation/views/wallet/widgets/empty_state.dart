import 'package:flutter/material.dart';

/// 空状态组件
class EmptyState extends StatelessWidget {
  final String text;
  final double? height;

  const EmptyState({
    super.key,
    required this.text,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final container = Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: container,
      );
    }

    return container;
  }
}
