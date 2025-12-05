import 'package:flutter/material.dart';

/// 交换按钮组件
class SwapButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SwapButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.swap_vert, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
