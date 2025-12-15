import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 图片来源选择器（拍照或从相册选择）
class ImageSourcePicker {
  /// 显示图片来源选择底部弹框
  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  /// 选择图片并返回文件路径
  static Future<String?> pickImage(
    BuildContext context, {
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final source = await show(context);
    if (source == null) return null;

    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(
      source: source,
      maxWidth: maxWidth ?? 1920,
      maxHeight: maxHeight ?? 1920,
      imageQuality: imageQuality ?? 85,
    );

    return image?.path;
  }
}
