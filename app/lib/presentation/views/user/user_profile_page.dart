import 'package:flutter/material.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_post.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_item.dart';
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

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  final FeedRepository _feedRepository = getIt<FeedRepository>();

  late TabController _tabController;
  List<FeedPost> _userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isCheckingFollow = true;

  // 用户基本信息
  String _nickname = '';
  String _avatar = '';
  String _signed = '';
  int _followingCount = 0;
  int _followersCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _checkFollowStatus();
    _loadUserPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 检查关注状态
  Future<void> _checkFollowStatus() async {
    try {
      final isFollowing = await _feedRepository.checkFollowStatus(
        followUserId: widget.userId,
      );
      setState(() {
        _isFollowing = isFollowing;
        _isCheckingFollow = false;
      });
    } catch (e) {
      setState(() => _isCheckingFollow = false);
    }
  }

  /// 加载用户发布的帖子
  Future<void> _loadUserPosts() async {
    setState(() => _isLoading = true);

    try {
      final posts = await _feedRepository.getUserPostList(
        userId: widget.userId,
        page: 1,
        pageSize: 20,
      );

      setState(() {
        _userPosts = posts;
        // 从第一个帖子获取用户基本信息
        if (posts.isNotEmpty) {
          final firstPost = posts.first;
          _nickname = firstPost.profile?.nickname ?? firstPost.username ?? '用户${widget.userId}';
          _avatar = firstPost.profile?.avatar ?? firstPost.avatar ?? '';
          _signed = ''; // UserProfile 没有 signed 字段，留空
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        MessageService.error('加载失败: ${e.toString()}');
      }
      // 打印详细错误信息用于调试
      debugPrint('加载用户帖子失败: $e');
    }
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
        title: Text(
          _nickname.isNotEmpty ? _nickname : '个人主页',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildTabBar(),
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
      padding: const EdgeInsets.all(16),
      child: Column(
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
          const SizedBox(height: 12),

          // 昵称
          Text(
            _nickname.isNotEmpty ? _nickname : '用户${widget.userId}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // 个性签名
          if (_signed.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _signed,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 16),

          // 关注/粉丝统计
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('关注', _followingCount),
              const SizedBox(width: 32),
              _buildStatItem('粉丝', _followersCount),
            ],
          ),

          const SizedBox(height: 16),

          // 关注按钮
          if (!_isCheckingFollow)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing
                      ? Colors.grey.shade200
                      : Colors.orange.shade600,
                  foregroundColor: _isFollowing
                      ? Colors.black87
                      : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  _isFollowing ? '已关注' : '关注',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 标签栏
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: Colors.orange.shade600,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: const [
          Tab(text: '发布内容'),
        ],
      ),
    );
  }

  /// 帖子列表
  Widget _buildPostsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '暂无帖子',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _userPosts.length,
      separatorBuilder: (context, index) => Container(
        height: 8,
        color: Colors.grey.shade100,
      ),
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return _buildPostItem(post);
      },
    );
  }

  /// 帖子项 - 使用 FeedItem 组件
  Widget _buildPostItem(FeedPost post) {
    // 优先使用 profile 数据，否则使用平铺字段，最后使用页面缓存的数据
    final username = post.profile?.displayNickname ??
                     post.username ??
                     (_nickname.isNotEmpty ? _nickname : '用户${widget.userId}');
    final avatar = post.profile?.displayAvatar ??
                   post.avatar ??
                   _avatar;

    // 转换图片列表为 Widget
    List<Widget>? mediaWidgets;
    final formattedImages = post.formattedImages;
    if (formattedImages.isNotEmpty) {
      mediaWidgets = formattedImages.map((imageUrl) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          ),
        );
      }).toList();
    }

    return FeedItem(
      postId: post.id,
      userId: post.userId ?? widget.userId, // 使用 post.userId，如果为空则使用页面 userId
      username: username,
      avatarAsset: avatar,
      time: post.getFormattedTime(),
      title: post.title,
      content: post.content ?? '',
      media: mediaWidgets,
      isVerified: post.isVerified ?? false,
      commentCount: post.commentCount,
      likeCount: post.likeCount,
      repostCount: post.quoteCount ?? 0,
      shareCount: post.shareCount ?? 0,
      isLiked: post.isLiked ?? false,
      menuIcon: Icons.more_horiz,
    );
  }
}
