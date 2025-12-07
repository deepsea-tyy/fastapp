import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:flutter/material.dart';

/// 通用信息说明底部弹窗
class InfoBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final String? buttonText;

  const InfoBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.buttonText,
  });

  /// 创建简单的文本内容弹窗
  factory InfoBottomSheet.simple({
    required String title,
    required String description,
    String? buttonText,
  }) {
    return InfoBottomSheet(
      title: title,
      buttonText: buttonText,
      content: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// 创建多行文本内容弹窗
  factory InfoBottomSheet.multiLine({
    required String title,
    required List<String> descriptions,
    String? buttonText,
  }) {
    return InfoBottomSheet(
      title: title,
      buttonText: buttonText,
      content: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: descriptions
              .map((desc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragHandle(),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          content,
          const SizedBox(height: 24),
          buildBottomSheetButton(
            onPressed: () => Navigator.of(context).pop(),
            text: buttonText ?? '确定',
          ),
        ],
      ),
    );
  }
}
