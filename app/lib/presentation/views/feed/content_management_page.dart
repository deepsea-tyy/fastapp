import 'package:flutter/material.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_post.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/presentation/views/common/action_bottom_sheet.dart';
import 'widgets/post_edit_page.dart';
import 'widgets/article_edit_page.dart';
import 'widgets/feed_detail.dart';

/// 内容管理页面
class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();
  final UserStore _userStore = getIt<UserStore>();
  final ScrollController _scrollController = ScrollController();

  List<FeedPost> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _currentPage = 1;
  final int _pageSize = 20;

  // 内容类型：1-帖子，2-文章，3-视频
  int _selectedContentType = 1;
  int _selectedContentTabIndex = 0;

  // 状态筛选：1-已发布，0-草稿，2-已下架
  int? _selectedStatus = 1;
  int _selectedStatusTabIndex = 0;

  final List<String> _contentTabs = ['帖子', '文章', '视频'];
  final List<String> _statusTabs = ['已发布', '草稿', '已下架'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onContentTabChanged(int index) {
    if (_selectedContentTabIndex == index) return;
    setState(() {
      _selectedContentTabIndex = index;
      _selectedContentType = index + 1;
      _currentPage = 1;
      _hasMore = true;
    });
    _loadPosts(isRefresh: true);
  }

  void _onStatusTabChanged(int index) {
    if (_selectedStatusTabIndex == index) return;
    setState(() {
      _selectedStatusTabIndex = index;
      // 0:已发布(1), 1:草稿(0), 2:已下架(2)
      switch (index) {
        case 0:
          _selectedStatus = 1;
          break;
        case 1:
          _selectedStatus = 0;
          break;
        case 2:
          _selectedStatus = 2;
          break;
      }
      _currentPage = 1;
      _hasMore = true;
    });
    _loadPosts(isRefresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts({bool isRefresh = false}) async {
    // 仅在首次加载或列表为空时显示 loading
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        // 只有列表为空时才显示 loading，避免切换闪烁
        if (_posts.isEmpty) {
          _isLoading = true;
        }
      });
    } else if (_isLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final userId = _userStore.currentUser?.id;
      if (userId == null) {
        throw Exception('未登录');
      }

      final posts = await _feedRepository.getUserPostList(
        userId: userId,
        type: _selectedContentType,
        status: _selectedStatus,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (isRefresh || _currentPage == 1) {
          _posts = posts;
        } else {
          _posts.addAll(posts);
        }
        _hasMore = posts.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        MessageService.error('加载失败: ${e.toString()}');
      }
      debugPrint('加载内容失败: $e');
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final userId = _userStore.currentUser?.id;
      if (userId == null) {
        throw Exception('未登录');
      }

      final posts = await _feedRepository.getUserPostList(
        userId: userId,
        type: _selectedContentType,
        status: _selectedStatus,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _posts.addAll(posts);
        _hasMore = posts.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
      debugPrint('加载更多失败: $e');
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts(isRefresh: true);
  }

  Future<void> _deletePost(FeedPost post) async {
    MessageService.confirm(
      title: '确认删除',
      message: '确定要删除这条内容吗？删除后无法恢复。',
      confirmText: '删除',
      cancelText: '取消',
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          await _feedRepository.deletePost(id: post.id);
          MessageService.success('删除成功');
          _refreshPosts();
        } catch (e) {
          MessageService.error('删除失败: ${e.toString()}');
        }
      },
    );
  }

  Future<void> _toggleStatus(FeedPost post) async {
    final isPublished = post.status == 1;
    final targetStatus = isPublished ? 2 : 1; // 1:已发布 -> 2:已下架, 2:已下架 -> 1:已发布
    final actionText = isPublished ? '下架' : '上架';

    MessageService.confirm(
      title: '确认$actionText',
      message: '确定要${actionText}这条内容吗？',
      confirmText: actionText,
      cancelText: '取消',
      confirmColor: isPublished ? Colors.orange : Colors.green,
      onConfirm: () async {
        try {
          await _feedRepository.updatePost(
            id: post.id,
            status: targetStatus,
          );
          MessageService.success('${actionText}成功');
          _refreshPosts();
        } catch (e) {
          MessageService.error('${actionText}失败: ${e.toString()}');
        }
      },
    );
  }

  Future<void> _showCreateMenu() async {
    await ActionBottomSheet.show(
      context,
      title: '创建内容',
      items: [
        ActionSheetItem(
          icon: Icons.article_outlined,
          text: '发布帖子',
          onTap: () {
            Navigator.pop(context);
            _navigateToPostEdit();
          },
          closeOnTap: false,
        ),
        ActionSheetItem(
          icon: Icons.description_outlined,
          text: '发布文章',
          onTap: () {
            Navigator.pop(context);
            _navigateToArticleEdit();
          },
          closeOnTap: false,
        ),
      ],
    );
  }

  void _navigateToPostEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PostEditPage(type: 1),
      ),
    ).then((_) => _refreshPosts());
  }

  void _navigateToArticleEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArticleEditPage(type: 2),
      ),
    ).then((_) => _refreshPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '内容管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              // 内容类型 Tab - 信息流样式
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 20.0 : 0),
                      child: _buildContentTab(index),
                    ),
                  ),
                ),
              ),
              // 状态筛选 Tab - 主页样式
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    _buildStatusTab('已发布', 0),
                    const SizedBox(width: 8),
                    _buildStatusTab('草稿', 1),
                    const SizedBox(width: 8),
                    _buildStatusTab('已下架', 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade600,
        onPressed: () => _showCreateMenu(),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '暂无内容',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final post = _posts[index];
          return _buildPostItem(post);
        },
      ),
    );
  }

  Widget _buildContentTab(int index) {
    final isSelected = _selectedContentTabIndex == index;
    return GestureDetector(
      onTap: () => _onContentTabChanged(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _contentTabs[index],
            style: TextStyle(
              fontSize: isSelected ? 17 : 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String label, int index) {
    final isSelected = _selectedStatusTabIndex == index;
    return GestureDetector(
      onTap: () => _onStatusTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(FeedPost post) {
    final title = post.title?.isNotEmpty == true ? post.title! : null;
    final content = post.content ?? '';
    final displayText = title ?? content;

    return GestureDetector(
      onTap: () => _navigateToDetail(post),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容预览
            Text(
              displayText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // 统计数据
            Row(
              children: [
                _buildStatItem(Icons.visibility_outlined, post.viewCount ?? 0),
                const SizedBox(width: 16),
                _buildStatItem(Icons.thumb_up_outlined, post.likeCount),
                const SizedBox(width: 16),
                _buildStatItem(Icons.comment_outlined, post.commentCount),
                const SizedBox(width: 16),
                _buildStatItem(Icons.repeat, post.quoteCount ?? 0),
                const Spacer(),
                _buildStatItem(Icons.star_border, post.collectCount ?? 0),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            // 操作按钮
            Row(
              children: [
                // 发布时间
                Expanded(
                  child: Text(
                    post.getFormattedTime(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                // 下架/上架按钮（已发布显示下架，已下架显示上架）
                if (_selectedStatus == 1)
                  _buildActionButton(
                    icon: Icons.archive_outlined,
                    label: '下架',
                    color: Colors.orange.shade700,
                    onPressed: () => _toggleStatus(post),
                  ),
                if (_selectedStatus == 2)
                  _buildActionButton(
                    icon: Icons.unarchive_outlined,
                    label: '上架',
                    color: Colors.green.shade700,
                    onPressed: () => _toggleStatus(post),
                  ),
                const SizedBox(width: 8),
                // 删除按钮
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: '删除',
                  color: Colors.red,
                  onPressed: () => _deletePost(post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(count),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}w';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _navigateToDetail(FeedPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: post.id,
          userId: post.userId ?? 0,
          username: post.username ?? '',
          time: post.getFormattedTime(),
          content: post.content ?? '',
          title: post.title,
          mediaUrls: post.formattedImages.isNotEmpty ? post.formattedImages : null,
          commentCount: post.commentCount,
          likeCount: post.likeCount,
          repostCount: post.quoteCount ?? 0,
          shareCount: post.shareCount ?? 0,
          avatarAsset: post.avatar ?? '',
          isVerified: post.isVerified ?? false,
          viewCount: post.viewCount ?? 0,
          type: post.type ?? 1,
          isLiked: post.isLiked ?? false,
        ),
      ),
    );
  }
}
