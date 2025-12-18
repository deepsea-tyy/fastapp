/// 移动端首页
///
/// 这是加密货币交易平台的移动端首页，包含以下主要模块：
/// - 加密货币行情：热门榜、涨幅榜、新币榜
/// - 开始您的加密货币之旅：功能介绍
/// - 交易"智"变跟单：跟单交易员展示
/// - 值得您信赖的平台：安全特性
/// - 底部导航栏：首页、行情、交易、合约、资产
///
/// 使用 Bitget 深色主题，适配移动端屏幕尺寸（375x667）。
///
/// 示例：
/// ```dart
/// MaterialApp(
///   home: HomeScreen(),
/// )
/// ```
import 'package:fastapp/presentation/views/home/widgets/top_bar.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/copy_trading_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/journey_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/mobile_crypto_list_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/trust_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/tologin_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/quick_entrance_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sticky_header_delegate.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_tabs.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_item.dart';
import 'package:fastapp/presentation/views/feed/widgets/sources_bar.dart';
import 'package:fastapp/presentation/views/feed/widgets/announcement_list.dart';
import 'package:fastapp/presentation/views/feed/widgets/news_list.dart';
import 'package:fastapp/presentation/views/feed/widgets/create_content_menu.dart';
import 'package:fastapp/presentation/views/feed/controllers/feed_controller.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/constants/app_backgrounds.dart';
import 'package:fastapp/core/widgets/common_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 移动端首页组件
///
/// 这是一个有状态的 Widget，使用 [StatefulWidget] 实现。
/// 页面采用垂直滚动的单列布局，所有内容模块按顺序排列。
///
/// 页面结构：
/// 1. [TopBar] - 顶部导航栏（Logo、搜索、菜单）
/// 2. [ToLoginSection] - 未登录时的欢迎区域（仅在未登录时显示）
/// 3. [MobileCryptoListSection] - 加密货币行情列表
/// 4. [JourneySection] - 开始您的加密货币之旅
/// 5. [CopyTradingSection] - 交易"智"变跟单
/// 6. [TrustSection] - 值得您信赖的平台
/// 7. [BottomNavBar] - 底部导航栏
class HomeScreen extends StatefulWidget {
  /// 创建移动端首页
  ///
  /// [key] 用于标识此 Widget 的键值
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserStore _userStore = getIt<UserStore>();
  late final FeedController _feedController;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;
  int _unreadMessageCount = 3; // TODO: 从实际数据源获取未读消息数

  @override
  void initState() {
    super.initState();
    // 页面初始化时，如果已登录但用户信息未加载，则获取用户信息
    if (_userStore.isLoggedIn && _userStore.currentUser == null) {
      _userStore.getUserInfo();
    }

    // 初始化 Feed 控制器
    _feedController = FeedController();
    _feedController.init();

    // 监听滚动，实现加载更多
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面重新可见时（例如从其他页面返回），检查是否需要刷新用户信息
    if (_userStore.isLoggedIn && _userStore.currentUser == null) {
      _userStore.getUserInfo();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _feedController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 判断是否显示浮动按钮：滚动超过屏幕高度的一半
    final screenHeight = MediaQuery.of(context).size.height;
    final shouldShow = _scrollController.position.pixels > screenHeight / 2;

    if (shouldShow != _showFab) {
      setState(() {
        _showFab = shouldShow;
      });
    }

    // 加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _feedController.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgrounds = AppBackgrounds.of(context);

    return Scaffold(
      backgroundColor: backgrounds.page,
      appBar: TopBar(
        unreadMessageCount: _unreadMessageCount,
        onMenuPressed: () {
          Navigator.of(context).pushNamed(Routes.userCenter);
        },
      ),
      floatingActionButton: _showFab ? _buildFloatingButtons() : null,
      body: Observer(
        builder: (_) {
          final isLoggedIn = _userStore.isLoggedIn;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 登录后显示的内容
              if (isLoggedIn) ...[
                // 快捷入口
                SliverToBoxAdapter(
                  child: Container(
                    color: backgrounds.card,
                    child: const QuickEntranceSection(),
                  ),
                ),

                // Feed 标签栏 - 吸顶效果的关键
                SliverPersistentHeader(
                  pinned: true, // 固定在顶部
                  delegate: StickyHeaderDelegate(
                    height: 50,
                    child: Container(
                      color: Colors.white,
                      child: ListenableBuilder(
                        listenable: _feedController,
                        builder: (context, _) {
                          return FeedTabs(
                            initialIndex: _feedController.currentTab,
                            onTabChanged: _feedController.switchTab,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 关注tab显示SourcesBar（也可以吸顶）
                ListenableBuilder(
                  listenable: _feedController,
                  builder: (context, _) {
                    if (_feedController.currentTab == 1) {
                      return SliverPersistentHeader(
                        pinned: true,
                        delegate: StickyHeaderDelegate(
                          height: 62,
                          child: const SourcesBar(),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                // Feed 内容列表
                ListenableBuilder(
                  listenable: _feedController,
                  builder: (context, _) => _buildFeedContent(backgrounds),
                ),
              ],

              // 未登录时显示的内容
              if (!isLoggedIn) ...[
                SliverToBoxAdapter(
                  child: Container(
                    color: backgrounds.card,
                    child: const ToLoginSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: backgrounds.card,
                    margin: const EdgeInsets.only(top: 8),
                    child: const MobileCryptoListSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: backgrounds.card,
                    margin: const EdgeInsets.only(top: 8),
                    child: const JourneySection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: backgrounds.card,
                    margin: const EdgeInsets.only(top: 8),
                    child: const CopyTradingSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: backgrounds.card,
                    margin: const EdgeInsets.only(top: 8),
                    child: const TrustSection(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeedContent(dynamic backgrounds) {
    final currentTab = _feedController.currentTab;

    // Tab 2: 公告
    if (currentTab == 2) {
      return const SliverToBoxAdapter(
        child: AnnouncementList(),
      );
    }

    // Tab 3: 新闻
    if (currentTab == 3) {
      return const SliverToBoxAdapter(
        child: NewsList(),
      );
    }

    // Tab 0 和 1: Feed 列表
    return _buildFeedList();
  }

  Widget _buildFeedList() {
    if (_feedController.isLoading && _feedController.feedList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_feedController.errorMessage != null &&
        _feedController.feedList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '加载失败',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                _feedController.errorMessage!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _feedController.loadFeedList(refresh: true),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_feedController.feedList.isEmpty) {
      String emptyTitle;
      String? emptyDescription;

      switch (_feedController.currentTab) {
        case 0:
          emptyTitle = '暂无推荐内容';
          emptyDescription = '当前没有可推荐的帖子，请稍后再试';
          break;
        case 1:
          emptyTitle = '暂无关注内容';
          emptyDescription = '您关注的用户还没有发布内容';
          break;
        default:
          emptyTitle = '暂无内容';
          emptyDescription = null;
      }

      return SliverFillRemaining(
        child: CommonEmptyState.noContent(
          title: emptyTitle,
          description: emptyDescription,
          actionText: '刷新',
          onAction: () => _feedController.loadFeedList(refresh: true),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _feedController.feedList.length) {
            return _feedController.isLoadingMore
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }

          final post = _feedController.feedList[index];
          final username = post.profile?.displayNickname ??
              post.username ??
              '用户${post.userId}';
          final avatar = post.profile?.displayAvatar ?? post.avatar ?? '';

          return Container(
            color: Colors.white,
            child: FeedItem(
              postId: post.id,
              userId: post.userId ?? 0,
              username: username,
              avatarAsset: avatar,
              time: post.getFormattedTime(),
              title: post.title,
              content: post.content ?? '',
              mediaUrls: post.formattedImages.isNotEmpty ? post.formattedImages : null,
              isVerified: post.isVerified ?? false,
              commentCount: post.commentCount,
              likeCount: post.likeCount,
              repostCount: post.quoteCount ?? 0,
              shareCount: post.shareCount ?? 0,
              isLiked: post.isLiked ?? false,
              type: post.type ?? 1, // 默认为帖子
              menuIcon: Icons.more_horiz,
            ),
          );
        },
        childCount: _feedController.feedList.length +
            (_feedController.hasMore ? 1 : 0),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return _buildFabButton(
      icon: Icons.edit_outlined,
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconColor: Theme.of(context).colorScheme.onPrimary,
      onTap: () => CreatePostMenu.show(context),
    );
  }

  Widget _buildFabButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: backgroundColor ?? theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: iconColor ?? colorScheme.onSurface,
            size: 26,
          ),
        ),
      ),
    );
  }
}

