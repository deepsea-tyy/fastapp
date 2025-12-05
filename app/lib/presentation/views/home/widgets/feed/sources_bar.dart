import 'package:flutter/material.dart';

/// 关注源列表组件
///
/// 横向滚动显示已关注的源（如 Binance News、Binance Academy）和"关注"按钮
class SourcesBar extends StatelessWidget {
  const SourcesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSourceItem(
            'Binance News',
            Colors.amber.shade700,
            'B',
            'BINANCE\nNEWS',
            isVerified: true,
          ),
          const SizedBox(width: 12),
          _buildSourceItem(
            'Binance Academy',
            Colors.amber.shade700,
            'B',
            'ACADEMY',
            isVerified: true,
          ),
          const SizedBox(width: 12),
          _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildSourceItem(
    String name,
    Color logoColor,
    String logoText,
    String logoSubtext, {
    bool isVerified = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      logoText,
                      style: TextStyle(
                        color: logoColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      logoSubtext,
                      style: TextStyle(
                        color: logoColor,
                        fontSize: 5,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isVerified)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.more_horiz,
            color: Colors.black87,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '关注',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
