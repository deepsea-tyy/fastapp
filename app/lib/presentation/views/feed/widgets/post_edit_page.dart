import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/presentation/views/common/image_upload_grid.dart';
import 'package:fastapp/core/services/message_service.dart';

/// 创建内容页面（支持帖子和文章）
class PostEditPage extends StatefulWidget {
  /// 帖子类型：1-帖子 2-文章
  final int type;

  const PostEditPage({
    super.key,
    required this.type,
  });

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  final FeedRepository _feedRepository = GetIt.instance<FeedRepository>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _uploadedImages = [];
  bool _isPublishing = false;

  bool get _isArticle => widget.type == 2;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      MessageService.warning('请输入内容');
      return;
    }

    if (_isArticle) {
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        MessageService.warning('请输入标题');
        return;
      }
    }

    setState(() => _isPublishing = true);

    try {
      final newPost = await _feedRepository.createPost(
        type: widget.type,
        contentType: _uploadedImages.isEmpty ? 1 : 2, // 1纯文本 2图文
        title: _isArticle ? _titleController.text.trim() : null,
        content: content,
        images: _uploadedImages.isEmpty ? null : _uploadedImages,
      );

      if (mounted) {
        MessageService.success('发布成功');
        Navigator.of(context).pop(newPost);
      }
    } catch (e) {
      MessageService.error('发布失败: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isArticle ? '发布文章' : '发布帖子',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isPublishing ? null : _publish,
              style: TextButton.styleFrom(
                backgroundColor: _isPublishing
                    ? colorScheme.primary.withOpacity(0.5)
                    : colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isPublishing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                  : const Text(
                      '发布',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isArticle) ...[
                _buildTitleInput(theme),
                const SizedBox(height: 16),
              ],
              _buildContentInput(theme),
              const SizedBox(height: 24),
              ImageUploadGrid(
                maxCount: 5,
                onImagesChanged: (images) {
                  setState(() {
                    _uploadedImages.clear();
                    _uploadedImages.addAll(images);
                  });
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: _titleController,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          hintText: '请输入标题',
          hintStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.3),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        maxLength: 100,
        buildCounter: (context,
            {required currentLength, required isFocused, maxLength}) {
          return Text(
            '$currentLength/$maxLength',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: _contentController,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: theme.textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          hintText: _isArticle ? '分享你的想法...' : '分享新鲜事...',
          hintStyle: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.3),
          ),
          border: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: 10,
        minLines: 6,
        maxLength: 5000,
        buildCounter: (context,
            {required currentLength, required isFocused, maxLength}) {
          return Text(
            '$currentLength/$maxLength',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }
}
