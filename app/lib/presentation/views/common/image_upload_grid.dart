import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fastapp/data/network/apis/attachment/attachment_api.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/views/common/safe_network_image.dart';
import 'image_picker_sheet.dart';

/// 通用图片上传网格组件
///
/// 支持多图上传、预览、删除功能，自动对接上传接口
class ImageUploadGrid extends StatefulWidget {
  /// 最大上传数量
  final int maxCount;

  /// 图片变化回调（返回已上传的图片URL列表）
  final ValueChanged<List<String>>? onImagesChanged;

  /// 初始图片URL列表
  final List<String>? initialImages;

  /// 图片尺寸
  final double imageSize;

  /// 图片间距
  final double spacing;

  /// 是否显示计数
  final bool showCount;

  /// 是否启用
  final bool enabled;

  const ImageUploadGrid({
    super.key,
    this.maxCount = 9,
    this.onImagesChanged,
    this.initialImages,
    this.imageSize = 80,
    this.spacing = 8,
    this.showCount = true,
    this.enabled = true,
  });

  @override
  State<ImageUploadGrid> createState() => _ImageUploadGridState();
}

class _ImageUploadGridState extends State<ImageUploadGrid> {
  final ImagePicker _imagePicker = ImagePicker();
  final AttachmentApi _attachmentApi = getIt<AttachmentApi>();

  /// 本地图片路径列表（用于预览）
  final List<String> _localImagePaths = [];

  /// 已上传的图片URL列表（用于提交）
  final List<String> _uploadedImageUrls = [];

  /// 上传中的索引列表
  final List<int> _uploadingIndexes = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      _uploadedImageUrls.addAll(widget.initialImages!);
      _localImagePaths.addAll(widget.initialImages!);
    }
  }

  /// 选择并上传图片
  Future<void> _pickAndUploadImage() async {
    if (!widget.enabled) return;
    if (_localImagePaths.length >= widget.maxCount) {
      _showSnackBar('最多只能上传${widget.maxCount}张图片');
      return;
    }

    try {
      final source = await ImagePickerSheet.show(context);
      if (source == null) return;

      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      // 添加到本地列表用于预览
      final currentIndex = _localImagePaths.length;
      setState(() {
        _localImagePaths.add(image.path);
        _uploadingIndexes.add(currentIndex);
      });

      // 开始上传
      try {
        final response = await _attachmentApi.upload(
          filePath: image.path,
          fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        final uploadedUrl = response['url'] as String?;
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          throw Exception('上传成功但未返回图片URL');
        }

        // 上传成功，添加到URL列表
        setState(() {
          _uploadedImageUrls.add(uploadedUrl);
          _uploadingIndexes.remove(currentIndex);
        });

        // 通知父组件
        widget.onImagesChanged?.call(_uploadedImageUrls);
      } catch (e) {
        // 上传失败，移除本地图片
        setState(() {
          _localImagePaths.removeAt(currentIndex);
          _uploadingIndexes.remove(currentIndex);
        });
        _showSnackBar('上传失败: ${e.toString()}');
      }
    } catch (e) {
      _showSnackBar('选择图片失败: ${e.toString()}');
    }
  }

  /// 移除图片
  void _removeImage(int index) {
    if (!widget.enabled) return;

    setState(() {
      _localImagePaths.removeAt(index);
      if (index < _uploadedImageUrls.length) {
        _uploadedImageUrls.removeAt(index);
      }
      // 重新计算上传中的索引
      _uploadingIndexes.clear();
      for (int i = 0; i < _localImagePaths.length; i++) {
        if (i >= _uploadedImageUrls.length) {
          _uploadingIndexes.add(i);
        }
      }
    });

    // 通知父组件
    widget.onImagesChanged?.call(_uploadedImageUrls);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showCount)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '上传图片',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_uploadedImageUrls.length}/${widget.maxCount}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        if (widget.showCount) const SizedBox(height: 12),
        _buildImageGrid(),
      ],
    );
  }

  Widget _buildImageGrid() {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      children: [
        ..._localImagePaths.asMap().entries.map((entry) {
          final index = entry.key;
          final imagePath = entry.value;
          final isUploading = _uploadingIndexes.contains(index);
          return _buildImageItem(imagePath, index, isUploading);
        }),
        if (_localImagePaths.length < widget.maxCount && widget.enabled)
          _buildAddImageButton(),
      ],
    );
  }

  Widget _buildImageItem(String imagePath, int index, bool isUploading) {
    final isNetworkImage = imagePath.startsWith('http');

    return Stack(
      children: [
        if (isNetworkImage)
          SafeNetworkImage(
            imageUrl: imagePath,
            width: widget.imageSize,
            height: widget.imageSize,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              width: widget.imageSize,
              height: widget.imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder();
              },
            ),
          ),
        // 上传中的遮罩和进度指示器
        if (isUploading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // 删除按钮
        if (!isUploading && widget.enabled)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: widget.imageSize,
      height: widget.imageSize,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        size: 32,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        width: widget.imageSize,
        height: widget.imageSize,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add_photo_alternate,
            size: widget.imageSize * 0.8,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
