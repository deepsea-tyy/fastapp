import 'package:flutter/material.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/repository/user/user_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_post.dart';
import 'package:fastapp/domain/entity/feed/feed_user_profile.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_item.dart';
import 'package:fastapp/presentation/views/feed/content_management_page.dart';
import 'package:fastapp/presentation/views/feed/profile_settings_page.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/utils/image_utils.dart';

/// 用户个人主页
class UserProfilePage extends StatefulWidget {
  final int userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();
  final UserRepository _userRepository = getIt<UserRepository>();
  final UserStore _userStore = getIt<UserStore>();
  final ScrollController _scrollController = ScrollController();

  List<FeedPost> _allPosts = []; // 所有内容（帖子+文章）
  List<FeedPost> _displayPosts = []; // 当前显示的内容
  bool _isInitialLoading = true; // 初次加载
  bool _isLoadingMore = false; // 加载更多
  bool _hasMore = true; // 是否还有更多数据
  bool _isFollowing = false;
  bool _isCheckingFollow = true;

  // 当前选中的内容类型：null-全部，1-帖子，2-文章
  int? _selectedContentType;

  // 分页参数
  int _currentPage = 1;
  final int _pageSize = 20;

  // 用户基本信息
  String _nickname = '';
  String _avatar = '';
  String _signed = '';
  int _followingCount = 0;
  int _followersCount = 0;
  int _likeCount = 0;
  int _shareCount = 0;
  bool _isVerified = false;

  // 判断是否是本人
  bool get _isCurrentUser {
    // 从 UserStore 获取当前登录用户ID进行比较
    final currentUserId = _userStore.currentUser?.id;
    return currentUserId != null && currentUserId == widget.userId;
  }

  @override
  void initState() {
    super.initState();

    // 先加载用户基本信息
    _loadUserBaseInfo();

    // 加载帖子列表
    _loadUserPosts();

    // 加载关注状态
    _checkFollowStatus();

    // 加载用户统计数据
    _loadUserStats();

    // 添加滚动监听以实现分页加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  /// 加载用户基本信息
  Future<void> _loadUserBaseInfo() async {
    try {
      final response = await _userRepository.getUserBaseInfo(userId: widget.userId);

      if (mounted) {
        setState(() {
          _nickname = response['nickname'] ?? '';
          _avatar = response['avatar'] ?? '';
          _signed = response['signed'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('加载用户基本信息失败: $e');
    }
  }

  /// 检查关注状态
  Future<void> _checkFollowStatus() async {
    try {
      final response = await _feedRepository.checkFollowStatus(
        followUserId: widget.userId,
      );

      // 解析关注状态
      final isFollowingValue = response['is_following'];
      final isFollowing = isFollowingValue is int ? isFollowingValue == 1 : (isFollowingValue as bool);

      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
          _isCheckingFollow = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingFollow = false);
      }
      debugPrint('获取关注状态失败: $e');
    }
  }

  /// 加载用户统计数据
  Future<void> _loadUserStats() async {
    try {
      final stats = await _feedRepository.getUserFollowStats(userId: widget.userId);

      if (stats != null) {
        setState(() {
          _followingCount = stats.followingCount;
          _followersCount = stats.followersCount;
          _likeCount = stats.totalLikes;
          _shareCount = stats.totalShares;
        });
      }
    } catch (e) {
      debugPrint('获取用户统计失败: $e');
    }
  }

  /// 加载用户发布的帖子
  Future<void> _loadUserPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
      });
    } else if (_isInitialLoading) {
      setState(() => _isInitialLoading = true);
    }

    try {
      final posts = await _feedRepository.getUserPostList(
        userId: widget.userId,
        type: _selectedContentType,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (isRefresh || _currentPage == 1) {
          _allPosts = posts;
        } else {
          _allPosts.addAll(posts);
        }

        // 从第一个帖子获取认证状态
        if (_allPosts.isNotEmpty) {
          final firstPost = _allPosts.first;
          _isVerified = firstPost.isVerified ?? false;
        }

        // 根据当前选中的类型过滤内容
        _filterPosts();

        _hasMore = posts.length >= _pageSize;
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
      });
      if (mounted) {
        MessageService.error('加载失败: ${e.toString()}');
      }
      debugPrint('加载用户帖子失败: $e');
    }
  }

  /// 加载更多帖子
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore || _isInitialLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final posts = await _feedRepository.getUserPostList(
        userId: widget.userId,
        type: _selectedContentType,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _allPosts.addAll(posts);
        _filterPosts();
        _hasMore = posts.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // 回退页码
      });
      debugPrint('加载更多失败: $e');
    }
  }

  /// 刷新帖子
  Future<void> _refreshPosts() async {
    await _loadUserPosts(isRefresh: true);
  }

  /// 更新显示列表（不再需要过滤，后端已根据 type 筛选）
  void _filterPosts() {
    _displayPosts = _allPosts;
  }

  /// 切换关注状态
  Future<void> _toggleFollow() async {
    try {
      await _feedRepository.toggleFollow(followUserId: widget.userId);
      setState(() {
        _isFollowing = !_isFollowing;
      });
    } catch (e) {
      if (mounted) {
        MessageService.error('操作失败: ${e.toString()}');
      }
    }
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
        centerTitle: true,
        actions: [
          // 本人时显示设置按钮和分享图标
          if (_isCurrentUser) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ContentManagementPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                minimumSize: const Size(80, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                '管理',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {
                // TODO: 分享功能
                MessageService.warning('分享');
              },
            ),
          ] else ...[
            // 非本人时显示关注按钮和分享图标
            TextButton(
              onPressed: _isCheckingFollow ? null : _toggleFollow,
              style: TextButton.styleFrom(
                backgroundColor: _isFollowing
                    ? Colors.grey.shade200
                    : Colors.orange.shade600,
                foregroundColor: _isFollowing
                    ? Colors.black87
                    : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                minimumSize: const Size(80, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isCheckingFollow
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isFollowing ? Colors.black87 : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      _isFollowing ? '已关注' : '关注',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {
                // TODO: 分享功能
                MessageService.warning('分享');
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildContentHeader(),
          Expanded(
            child: _buildPostsList(),
          ),
        ],
      ),
    );
  }

  /// 个人信息头部
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像和基本信息行
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _buildAvatar(),
                ),
              ),
              const SizedBox(width: 16),

              // 右侧信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 昵称和认证标志
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _nickname.isNotEmpty ? _nickname : '用户${widget.userId}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // 认证标志
                              if (_isVerified) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // 本人时显示设置按钮
                        if (_isCurrentUser) ...[
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfileSettingsPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.settings_outlined,
                                size: 18,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // 个性签名
                    const SizedBox(height: 8),
                    Text(
                      _signed.isNotEmpty ? _signed : '什么也没有..',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 统计数据
          Row(
            children: [
              _buildStatItem('关注', _followingCount),
              const SizedBox(width: 24),
              _buildStatItem('粉丝', _followersCount),
              const SizedBox(width: 24),
              _buildStatItem('点赞', _likeCount),
              const SizedBox(width: 24),
              _buildStatItem('分享', _shareCount),
            ],
          ),
        ],
      ),
    );
  }

  /// 头像
  Widget _buildAvatar() {
    if (_avatar.isEmpty || !ImageUtils.isValidImagePath(_avatar)) {
      return Center(
        child: Text(
          _nickname.isNotEmpty ? _nickname[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Image.network(
      ImageUtils.formatSingleImagePath(_avatar),
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            _nickname.isNotEmpty ? _nickname[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  /// 统计项
  Widget _buildStatItem(String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 格式化数字显示
  String _formatCount(int count) {
    if (count >= 1000000) {
      final millions = (count / 1000000).toStringAsFixed(1);
      return '${millions}M+';
    } else if (count >= 1000) {
      final thousands = (count / 1000).toStringAsFixed(1);
      return '${thousands}K+';
    }
    return count.toString();
  }

  /// 内容标题栏
  Widget _buildContentHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 内容标题
          const Text(
            '内容',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          // 帖子和文章切换按钮
          Row(
            children: [
              _buildContentTypeButton('帖子', 1),
              const SizedBox(width: 8),
              _buildContentTypeButton('文章', 2),
            ],
          ),
        ],
      ),
    );
  }

  /// 内容类型切换按钮
  Widget _buildContentTypeButton(String label, int? type) {
    final isSelected = _selectedContentType == type;
    return GestureDetector(
      onTap: () {
        if (_selectedContentType == type) {
          // 如果点击的是当前已选中的，则取消选择
          setState(() {
            _selectedContentType = null;
          });
        } else {
          // 否则选中新类型
          setState(() {
            _selectedContentType = type;
          });
        }
        // 重新加载第一页数据
        _currentPage = 1;
        _loadUserPosts(isRefresh: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// 帖子列表
  Widget _buildPostsList() {
    // 初次加载时显示loading
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 没有数据时显示空状态
    if (_displayPosts.isEmpty) {
      String emptyText = '暂无内容';
      if (_selectedContentType == 1) {
        emptyText = '暂无帖子';
      } else if (_selectedContentType == 2) {
        emptyText = '暂无文章';
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              emptyText,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // 显示列表（带下拉刷新）
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _displayPosts.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => Container(
          height: 8,
          color: Colors.grey.shade100,
        ),
        itemBuilder: (context, index) {
          // 显示加载更多指示器
          if (index == _displayPosts.length) {
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

          final post = _displayPosts[index];
          return _buildPostItem(post);
        },
      ),
    );
  }

  /// 帖子项 - 使用 FeedItem 组件
  Widget _buildPostItem(FeedPost post) {
    return FeedItem(
      postId: post.id,
      profile: post.profile!,
      time: post.getFormattedTime(),
      title: post.title,
      content: post.content ?? '',
      mediaUrls: post.formattedImages.isNotEmpty ? post.formattedImages : null,
      commentCount: post.commentCount,
      likeCount: post.likeCount,
      repostCount: post.quoteCount ?? 0,
      shareCount: post.shareCount ?? 0,
      isLiked: post.isLiked ?? false,
      type: post.type ?? 1,
      menuIcon: Icons.more_horiz,
      onRemove: () {
        // 个人主页删除回调：从列表中移除该帖子
        setState(() {
          _displayPosts.removeWhere((p) => p.id == post.id);
        });
      },
    );
  }
}
