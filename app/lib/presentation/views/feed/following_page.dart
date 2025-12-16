import 'package:flutter/material.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/views/feed/notification_settings_page.dart';

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

  // 模拟数据，实际应从API获取
  final List<FollowingUser> _followingUsers = [
    FollowingUser(
      id: 1,
      username: 'Binance News',
      description: 'Follow Binance News to stay on top ...',
      avatarUrl: '',
      isVerified: true,
      isFollowing: true,
    ),
    FollowingUser(
      id: 2,
      username: 'Binance Academy',
      description: 'Your complete guide to crypto and b...',
      avatarUrl: '',
      isVerified: true,
      isFollowing: true,
    ),
  ];

  final List<FollowingUser> _suggestedUsers = [
    FollowingUser(
      id: 3,
      username: 'Crypto Daily',
      description: 'Daily crypto news and analysis',
      avatarUrl: '',
      isVerified: false,
      isFollowing: false,
    ),
    FollowingUser(
      id: 4,
      username: 'Trading Hub',
      description: 'Professional trading insights',
      avatarUrl: '',
      isVerified: true,
      isFollowing: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow(FollowingUser user) async {
    try {
      await _feedRepository.toggleFollow(followUserId: user.id);
      setState(() {
        user.isFollowing = !user.isFollowing;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: ${e.toString()}')),
        );
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
            icon: Icon(
              Icons.hexagon_outlined,
              color: Colors.grey.shade700,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
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

  /// 标签栏
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
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
        tabs: const [
          Tab(text: '关注'),
          Tab(text: '你可能感兴趣的人'),
        ],
      ),
    );
  }

  /// 关注列表
  Widget _buildFollowingList() {
    if (_followingUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无关注',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去发现感兴趣的人吧',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _followingUsers.length,
      itemBuilder: (context, index) {
        return _buildUserItem(_followingUsers[index]);
      },
    );
  }

  /// 推荐列表
  Widget _buildSuggestedList() {
    if (_suggestedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无推荐',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _suggestedUsers.length,
      itemBuilder: (context, index) {
        return _buildUserItem(_suggestedUsers[index]);
      },
    );
  }

  /// 用户项
  Widget _buildUserItem(FollowingUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 头像
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _buildAvatar(user),
                ),
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
          const SizedBox(width: 12),

          // 用户名和描述
          Expanded(
            child: Column(
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
            ),
          ),

          const SizedBox(width: 12),

          // 关注按钮
          _buildFollowButton(user),
        ],
      ),
    );
  }

  /// 头像内容
  Widget _buildAvatar(FollowingUser user) {
    if (user.username.contains('Binance News')) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'B',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'BINANCE\nNEWS',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 6,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (user.username.contains('Binance Academy')) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'B',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ACADEMY',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // 默认头像
    return Icon(
      Icons.person,
      size: 28,
      color: Colors.grey.shade600,
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
