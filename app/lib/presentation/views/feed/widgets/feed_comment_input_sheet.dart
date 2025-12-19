import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/common/image_upload_grid.dart';

/// Feed 评论输入底部弹框（通用组件）
///
/// 用于发布评论、回复、转发等场景
class FeedCommentInputSheet extends StatefulWidget {
  final String? placeholder;
  final Function(String content, List<String> images)? onSend;
  final bool showRepostOption;
  final int? parentId;
  final int? replyToUserId;
  final String? replyToUsername;

  const FeedCommentInputSheet({
    super.key,
    this.placeholder,
    this.onSend,
    this.showRepostOption = true,
    this.parentId,
    this.replyToUserId,
    this.replyToUsername,
  });

  /// 显示评论输入弹框
  static void show(
    BuildContext context, {
    String? placeholder,
    Function(String content, List<String> images)? onSend,
    bool showRepostOption = true,
    int? parentId,
    int? replyToUserId,
    String? replyToUsername,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedCommentInputSheet(
        placeholder: placeholder,
        onSend: onSend,
        showRepostOption: showRepostOption,
        parentId: parentId,
        replyToUserId: replyToUserId,
        replyToUsername: replyToUsername,
      ),
    );
  }

  @override
  State<FeedCommentInputSheet> createState() => _FeedCommentInputSheetState();
}

class _FeedCommentInputSheetState extends State<FeedCommentInputSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isRepostChecked = false;
  List<String> _uploadedImages = [];
  String? _selectedLocation; // 已选择的位置

  @override
  void initState() {
    super.initState();
    // 延迟自动聚焦，等待动画完成
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(),
                if (_uploadedImages.isNotEmpty || _selectedLocation != null) ...[
                  const SizedBox(height: 8),
                  _buildAttachments(),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            child: _buildBottomBar(),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  /// 输入框
  Widget _buildInputField() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      maxLines: 5,
      minLines: 3,
      decoration: InputDecoration(
        hintText: widget.placeholder ?? '添加回复...',
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 12.0,
        ),
        isDense: true,
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  /// 已选择的附件（图片和位置）
  Widget _buildAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已选择的图片
        if (_uploadedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ImageUploadGrid(
              maxCount: 9,
              imageSize: 80,
              spacing: 8,
              showCount: false,
              initialImages: _uploadedImages,
              onImagesChanged: (images) {
                setState(() {
                  _uploadedImages = images;
                });
              },
            ),
          ),
        // 已选择的位置
        if (_selectedLocation != null) _buildLocationItem(),
      ],
    );
  }

  /// 位置项
  Widget _buildLocationItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            _selectedLocation!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedLocation = null;
              });
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 底部操作栏
  Widget _buildBottomBar() {
    return Row(
      children: [
        _buildActionIcon(Icons.emoji_emotions_outlined, onTap: () {
          // TODO: 显示表情选择器
        }),
        const SizedBox(width: 16),
        _buildActionIcon(Icons.image_outlined, onTap: () {
          // 触发图片上传
          if (_uploadedImages.isEmpty) {
            // 首次添加时，展开图片上传组件
            setState(() {
              _uploadedImages = [];
            });
          }
        }),
        const SizedBox(width: 16),
        _buildActionIcon(Icons.alternate_email, onTap: () {
          // TODO: @某人
        }),
        const SizedBox(width: 16),
        if (widget.showRepostOption) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isRepostChecked = !_isRepostChecked;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _isRepostChecked ? Colors.amber : Colors.transparent,
                      border: Border.all(
                        color: _isRepostChecked ? Colors.amber : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _isRepostChecked
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.black87,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '评论并转发',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else
          const Spacer(),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            final content = _textController.text.trim();
            if (content.isEmpty) return;
            widget.onSend?.call(content, _uploadedImages);
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '发送',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 24,
        color: Colors.black87,
      ),
    );
  }
}
