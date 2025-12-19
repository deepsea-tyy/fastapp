import 'package:flutter/material.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/views/feed/feed_notify_settings.dart';
import 'package:fastapp/presentation/views/feed/feed_profile.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/core/services/message_service.dart';

/// 关注页面
///
/// 显示用户关注的账号列表和推荐关注的账号
class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedRepository _feedRepository = getIt<FeedRepository>();

  // 关注列表状态
  final _followingState = _ListState();

  // 推荐列表状态
  final _suggestedState = _ListState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _followingState.scrollController.addListener(_onFollowingScroll);
    _suggestedState.scrollController.addListener(_onSuggestedScroll);
    _loadFollowingList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _followingState.dispose();
    _suggestedState.dispose();
    super.dispose();
  }

  /// Tab 切换监听
  void _onTabChanged() {
    if (_tabController.index == 1 && _suggestedState.users.isEmpty) {
      _loadMayInterestedList();
    }
  }

  /// 关注列表滚动监听
  void _onFollowingScroll() {
    _checkLoadMore(_followingState, _loadMoreFollowing);
  }

  /// 感兴趣列表滚动监听
  void _onSuggestedScroll() {
    _checkLoadMore(_suggestedState, _loadMoreSuggested);
  }

  /// 检查是否需要加载更多
  void _checkLoadMore(_ListState state, VoidCallback loadMore) {
    final controller = state.scrollController;
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      if (!state.isLoadingMore && state.hasMore) {
        loadMore();
      }
    }
  }

  /// 加载关注列表
  Future<void> _loadFollowingList({bool isRefresh = false}) async {
    await _loadList(
      state: _followingState,
      isRefresh: isRefresh,
      fetchData: (page) => _feedRepository.getFollowingUserList(
        page: page,
        pageSize: 20,
      ),
      mapUser: (item) => _mapToFollowingUser(item, isFollowing: true),
      errorMessage: '加载失败',
    );
  }

  /// 加载更多关注列表
  Future<void> _loadMoreFollowing() async {
    await _loadMoreList(
      state: _followingState,
      fetchData: (page) => _feedRepository.getFollowingUserList(
        page: page,
        pageSize: 20,
      ),
      mapUser: (item) => _mapToFollowingUser(item, isFollowing: true),
    );
  }

  /// 加载可能感兴趣的人列表
  Future<void> _loadMayInterestedList({bool isRefresh = false}) async {
    await _loadList(
      state: _suggestedState,
      isRefresh: isRefresh,
      fetchData: (page) => _feedRepository.getMayInterestedList(
        page: page,
        pageSize: 20,
      ),
      mapUser: (item) => _mapToFollowingUser(item, isFollowing: false),
      errorMessage: '加载感兴趣人列表失败',
    );
  }

  /// 加载更多感兴趣人列表
  Future<void> _loadMoreSuggested() async {
    await _loadMoreList(
      state: _suggestedState,
      fetchData: (page) => _feedRepository.getMayInterestedList(
        page: page,
        pageSize: 20,
      ),
      mapUser: (item) => _mapToFollowingUser(item, isFollowing: false),
    );
  }

  /// 通用加载列表逻辑
  Future<void> _loadList({
    required _ListState state,
    required bool isRefresh,
    required Future<List<Map<String, dynamic>>> Function(int page) fetchData,
    required FollowingUser Function(Map<String, dynamic>) mapUser,
    required String errorMessage,
  }) async {
    if (isRefresh) {
      state.page = 1;
      state.hasMore = true;
    } else {
      setState(() => state.isLoading = true);
    }

    try {
      final data = await fetchData(state.page);
      final users = data.map(mapUser).toList();

      setState(() {
        state.users = users;
        state.hasMore = data.length >= 20;
        state.isLoading = false;
      });
    } catch (e) {
      setState(() => state.isLoading = false);
      if (mounted) {
        MessageService.error('$errorMessage: ${e.toString()}');
      }
    }
  }

  /// 通用加载更多逻辑
  Future<void> _loadMoreList({
    required _ListState state,
    required Future<List<Map<String, dynamic>>> Function(int page) fetchData,
    required FollowingUser Function(Map<String, dynamic>) mapUser,
  }) async {
    if (state.isLoadingMore || !state.hasMore) return;

    setState(() => state.isLoadingMore = true);

    try {
      state.page++;
      final data = await fetchData(state.page);
      final newUsers = data.map(mapUser).toList();

      setState(() {
        state.users.addAll(newUsers);
        state.hasMore = data.length >= 20;
        state.isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        state.page--;
        state.isLoadingMore = false;
      });
      if (mounted) {
        MessageService.error('加载更多失败: ${e.toString()}');
      }
    }
  }

  /// 将接口数据映射为 FollowingUser
  FollowingUser _mapToFollowingUser(
    Map<String, dynamic> item, {
    required bool isFollowing,
  }) {
    final userId = item['follow_user_id'] as int? ?? (item['user_id'] as int? ?? 0);
    final nickname = (item['nickname'] as String?)?.trim();
    final avatar = (item['avatar'] as String?) ?? '';

    return FollowingUser(
      id: userId,
      username: nickname?.isNotEmpty == true ? nickname! : '用户$userId',
      description: _getDescription(item),
      avatarUrl: avatar,
      isVerified: false,
      isFollowing: isFollowing,
    );
  }

  /// 获取描述文本（优先级：title > content > signed）
  String _getDescription(Map<String, dynamic> item) {
    final title = (item['title'] as String?)?.trim();
    final content = (item['content'] as String?)?.trim();
    final signed = (item['signed'] as String?)?.trim();

    if (title?.isNotEmpty == true) return title!;
    if (content?.isNotEmpty == true) return content!;
    if (signed?.isNotEmpty == true) return signed!;
    return '暂无新信息';
  }

  /// 切换关注状态
  Future<void> _toggleFollow(FollowingUser user) async {
    // 取消关注需要确认
    if (user.isFollowing) {
      final confirmed = await MessageService.confirm(
        title: '取消关注',
        message: '确定要取消关注 ${user.username} 吗？',
        confirmText: '确定',
        cancelText: '取消',
        onConfirm: () async => await _doToggleFollow(user),
      );
      if (confirmed != true) return;
    } else {
      await _doToggleFollow(user);
    }
  }

  /// 执行关注/取消关注操作
  Future<void> _doToggleFollow(FollowingUser user) async {
    try {
      await _feedRepository.toggleFollow(followUserId: user.id);
      setState(() => user.isFollowing = !user.isFollowing);
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowingList(),
                _buildSuggestedList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '关注',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.hexagon_outlined, color: Colors.grey.shade700),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FeedNotifySettings(),
            ),
          ),
        ),
      ],
    );
  }

  /// 标签栏
  Widget _buildTabBar() {
    return TabBar(
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
      tabs: const [
        Tab(text: '关注'),
        Tab(text: '你可能感兴趣的人'),
      ],
    );
  }

  /// 关注列表
  Widget _buildFollowingList() {
    return _buildListView(
      state: _followingState,
      onRefresh: () => _loadFollowingList(isRefresh: true),
      emptyIcon: Icons.people_outline,
      emptyTitle: '暂无关注',
      emptySubtitle: '去发现感兴趣的人吧',
    );
  }

  /// 推荐列表
  Widget _buildSuggestedList() {
    return _buildListView(
      state: _suggestedState,
      onRefresh: () => _loadMayInterestedList(isRefresh: true),
      emptyIcon: Icons.search_off,
      emptyTitle: '暂无推荐',
    );
  }

  /// 通用列表视图
  Widget _buildListView({
    required _ListState state,
    required Future<void> Function() onRefresh,
    required IconData emptyIcon,
    required String emptyTitle,
    String? emptySubtitle,
  }) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.users.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildEmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              subtitle: emptySubtitle,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: state.scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.users.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.users.length) {
            return _buildLoadingIndicator(state.isLoadingMore);
          }
          return _buildUserItem(state.users[index]);
        },
      ),
    );
  }

  /// 加载指示器
  Widget _buildLoadingIndicator(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const SizedBox.shrink(),
    );
  }

  /// 空状态
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  /// 用户项
  Widget _buildUserItem(FollowingUser user) {
    return InkWell(
      onTap: () => _navigateToProfile(user.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildUserAvatar(user),
            const SizedBox(width: 12),
            Expanded(child: _buildUserInfo(user)),
            const SizedBox(width: 12),
            _buildFollowButton(user),
          ],
        ),
      ),
    );
  }

  /// 用户头像
  Widget _buildUserAvatar(FollowingUser user) {
    return GestureDetector(
      onTap: () => _navigateToProfile(user.id),
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: ClipOval(child: _buildAvatar(user)),
          ),
          if (user.isVerified)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 头像内容
  Widget _buildAvatar(FollowingUser user) {
    if (user.avatarUrl.isEmpty || !ImageUtils.isValidImagePath(user.avatarUrl)) {
      return _buildDefaultAvatar(user);
    }

    return Image.network(
      ImageUtils.formatSingleImagePath(user.avatarUrl),
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildDefaultAvatar(user),
    );
  }

  /// 默认头像
  Widget _buildDefaultAvatar(FollowingUser user) {
    return Center(
      child: Text(
        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 用户信息
  Widget _buildUserInfo(FollowingUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.username,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 关注按钮
  Widget _buildFollowButton(FollowingUser user) {
    return GestureDetector(
      onTap: () => _toggleFollow(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: user.isFollowing ? Colors.grey.shade200 : Colors.orange.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          user.isFollowing ? '已关注' : '关注',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: user.isFollowing ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }

  /// 跳转到用户主页
  void _navigateToProfile(int userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: userId),
      ),
    );
  }
}

/// 列表状态管理类
class _ListState {
  List<FollowingUser> users = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int page = 1;
  bool hasMore = true;
  final ScrollController scrollController = ScrollController();

  void dispose() {
    scrollController.dispose();
  }
}

/// 关注用户数据模型
class FollowingUser {
  final int id;
  final String username;
  final String description;
  final String avatarUrl;
  final bool isVerified;
  bool isFollowing;

  FollowingUser({
    required this.id,
    required this.username,
    required this.description,
    required this.avatarUrl,
    required this.isVerified,
    required this.isFollowing,
  });
}
