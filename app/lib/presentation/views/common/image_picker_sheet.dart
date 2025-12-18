import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'action_bottom_sheet.dart';

class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({super.key});

  static Future<ImageSource?> show(BuildContext context) {
    final items = [
      ActionSheetItem(
        icon: Icons.photo_camera,
        text: '拍照',
        value: ImageSource.camera,
      ),
      ActionSheetItem(
        icon: Icons.photo_library,
        text: '从相册选择',
        value: ImageSource.gallery,
      ),
    ];

    return ActionBottomSheet.show<ImageSource>(
      context,
      title: '选择图片',
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
