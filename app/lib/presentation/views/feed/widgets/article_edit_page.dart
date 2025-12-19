import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:get_it/get_it.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/presentation/views/common/image_upload_grid.dart';
import 'package:fastapp/core/services/message_service.dart';

/// HTML 富文本编辑器页面
///
/// 使用 html_editor_enhanced 提供富文本编辑功能
class ArticleEditPage extends StatefulWidget {
  /// 帖子类型：1-帖子 2-文章
  final int type;

  /// 初始标题（编辑时使用）
  final String? initialTitle;

  /// 初始内容（编辑时使用，HTML 格式）
  final String? initialContent;

  const ArticleEditPage({
    super.key,
    required this.type,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<ArticleEditPage> createState() => _ArticleEditPageState();
}

class _ArticleEditPageState extends State<ArticleEditPage> {
  final FeedRepository _feedRepository = GetIt.instance<FeedRepository>();
  final TextEditingController _titleController = TextEditingController();
  final HtmlEditorController _htmlEditorController = HtmlEditorController();
  final List<String> _uploadedImages = [];
  bool _isPublishing = false;
  int _contentLength = 0;
  static const int _maxContentLength = 5000;

  bool get _isArticle => widget.type == 2;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    // 获取 HTML 内容
    final htmlContent = await _htmlEditorController.getText();

    if (htmlContent.isEmpty || htmlContent == '<p></p>' || htmlContent == '<p><br></p>') {
      MessageService.warning('请输入内容');
      return;
    }

    // 检查字数限制
    if (_contentLength > _maxContentLength) {
      MessageService.warning('内容超过字数限制（最多$_maxContentLength字）');
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
        contentType: 2, // 文章默认是图文类型
        title: _isArticle ? _titleController.text.trim() : null,
        content: htmlContent,
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
                    ? colorScheme.primary.withAlpha(128)
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
                          Colors.white.withAlpha(178),
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
              // 标题输入框（仅文章显示）
              if (_isArticle) ...[
                _buildTitleInput(theme),
                const SizedBox(height: 16),
              ],

              // HTML 富文本编辑器
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: HtmlEditor(
                  controller: _htmlEditorController,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: _isArticle ? '分享你的想法...' : '分享新鲜事...',
                    initialText: widget.initialContent,
                    shouldEnsureVisible: true,
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    toolbarPosition: ToolbarPosition.belowEditor,  // 工具栏在底部
                    toolbarType: ToolbarType.nativeScrollable,
                    // 隐藏字数统计等底部信息
                    renderBorder: false,
                    defaultToolbarButtons: [
                      // 移除了 StyleButtons 和 FontSettingButtons（下拉选项）
                      const FontButtons(
                        clearAll: false,
                        strikethrough: false,
                        superscript: false,
                        subscript: false,
                      ),
                      const ColorButtons(),
                      const ListButtons(listStyles: false),
                      const ParagraphButtons(
                        textDirection: false,
                        lineHeight: false,
                        caseConverter: false,
                        decreaseIndent: false,
                        increaseIndent: false,
                      ),
                      // 移除了 InsertButtons（包含链接等插入功能）
                    ],
                  ),
                  otherOptions: const OtherOptions(
                    height: 385,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  callbacks: Callbacks(
                    onChangeContent: (String? changed) {
                      // 计算纯文本长度（去掉 HTML 标签）
                      if (changed != null) {
                        final text = changed.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                        setState(() {
                          _contentLength = text.length;
                        });
                      }
                    },
                  ),
                ),
              ),

              // 字数统计
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$_contentLength/$_maxContentLength',
                  style: TextStyle(
                    fontSize: 12,
                    color: _contentLength > _maxContentLength
                        ? Colors.red
                        : theme.textTheme.bodySmall?.color?.withAlpha(128),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 图片上传区域
              ImageUploadGrid(
                maxCount: 5,
                onImagesChanged: (images) {
                  setState(() {
                    _uploadedImages.clear();
                    _uploadedImages.addAll(images);
                  });
                },
              ),

              const SizedBox(height: 16),
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
            color: theme.textTheme.bodyLarge?.color?.withAlpha(77),
          ),
          border: InputBorder.none,
          filled: false,
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
              color: theme.textTheme.bodySmall?.color?.withAlpha(128),
            ),
          );
        },
      ),
    );
  }
}
