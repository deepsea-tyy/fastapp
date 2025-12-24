import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_tabs.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_item.dart';
import 'package:fastapp/presentation/views/feed/widgets/sources_bar.dart';
import 'package:fastapp/presentation/views/feed/widgets/announcement_list.dart';
import 'package:fastapp/presentation/views/feed/widgets/news_list.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_post.dart';
import 'package:fastapp/core/services/blocked_users_service.dart';
import 'package:fastapp/core/services/not_interested_service.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/views/common/empty_state.dart';
import 'package:fastapp/core/theme/app_theme_extension.dart';

/// 信息流区域组件
///
/// 包含顶部标签栏和信息流帖子列表
class FeedSection extends StatefulWidget {
  const FeedSection({super.key});

  @override
  State<FeedSection> createState() => _FeedSectionState();
}

class _FeedSectionState extends State<FeedSection> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();
  final BlockedUsersService _blockedUsersService = getIt<BlockedUsersService>();
  final NotInterestedService _notInterestedService = getIt<NotInterestedService>();

  int _currentTab = 0;

  // 为每个tab缓存数据，避免切换时闪烁
  final Map<int, List<FeedPost>> _tabDataCache = {};
  final Map<int, int> _tabPageCache = {};
  final Map<int, bool> _tabHasMoreCache = {};

  List<FeedPost> _feedList = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFeedList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadFeedList({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    // 只有在列表为空时才显示loading状态，避免刷新时的闪烁
    setState(() {
      if (_feedList.isEmpty) {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final List<FeedPost> newList;

      // 根据当前标签加载不同的数据源
      if (_currentTab == 1) {
        // 关注
        newList = await _feedRepository.getFollowingFeedList(
          page: _currentPage,
          pageSize: _pageSize,
        );
      } else if (_currentTab == 0) {
        // 推荐（最新）
        newList = await _feedRepository.getFeedList(
          filter: 'latest',
          page: _currentPage,
          pageSize: _pageSize,
        );
      } else {
        // 公告和新闻暂时返回空列表
        newList = [];
      }

      setState(() {
        if (refresh) {
          _feedList = newList;
        } else {
          _feedList.addAll(newList);
        }
        _hasMore = newList.length >= _pageSize;
        _isLoading = false;

        // 更新当前tab的缓存（深拷贝List）
        _tabDataCache[_currentTab] = List<FeedPost>.from(_feedList);
        _tabPageCache[_currentTab] = _currentPage;
        _tabHasMoreCache[_currentTab] = _hasMore;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;

    try {
      final List<FeedPost> newList;

      if (_currentTab == 1) {
        newList = await _feedRepository.getFollowingFeedList(
          page: _currentPage,
          pageSize: _pageSize,
        );
      } else if (_currentTab == 0) {
        newList = await _feedRepository.getFeedList(
          filter: 'latest',
          page: _currentPage,
          pageSize: _pageSize,
        );
      } else {
        newList = [];
      }

      setState(() {
        _feedList.addAll(newList);
        _hasMore = newList.length >= _pageSize;
        _isLoadingMore = false;

        // 更新当前tab的缓存（深拷贝List）
        _tabDataCache[_currentTab] = List<FeedPost>.from(_feedList);
        _tabPageCache[_currentTab] = _currentPage;
        _tabHasMoreCache[_currentTab] = _hasMore;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // 回退页码
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕高度，为信息流区域分配合适的高度
    final screenHeight = MediaQuery.of(context).size.height;
    final feedHeight = screenHeight - 200; // 减去顶部导航栏和快捷入口的高度

    // 获取主题颜色
    final backgroundTheme = context.backgroundTheme;

    return Container(
      color: backgroundTheme.page,
      height: feedHeight,
      child: Column(
        children: [
          FeedTabs(
            initialIndex: _currentTab,
            onTabChanged: (index) {
              setState(() {
                // 保存当前tab的数据到缓存（深拷贝List，避免引用共享）
                _tabDataCache[_currentTab] = List<FeedPost>.from(_feedList);
                _tabPageCache[_currentTab] = _currentPage;
                _tabHasMoreCache[_currentTab] = _hasMore;

                // 切换到新tab
                _currentTab = index;

                // 从缓存恢复新tab的数据（深拷贝List，避免引用共享）
                if (_tabDataCache.containsKey(index)) {
                  _feedList = List<FeedPost>.from(_tabDataCache[index]!);
                  _currentPage = _tabPageCache[index] ?? 1;
                  _hasMore = _tabHasMoreCache[index] ?? true;
                } else {
                  // 新tab没有缓存，清空列表
                  _feedList = [];
                  _currentPage = 1;
                  _hasMore = true;
                }
              });

              // 如果新tab没有数据，加载数据
              if (_feedList.isEmpty) {
                _loadFeedList(refresh: true);
              }
            },
          ),
          // 关注tab显示SourcesBar
          if (_currentTab == 1) ...[
            const SourcesBar(),
          ],
          // 使用Stack让所有tab内容同时存在，通过Offstage控制显示
          Expanded(
            child: Stack(
              children: [
                // Tab 0和1：发现和关注（共用同一个列表视图）
                Offstage(
                  offstage: _currentTab != 0 && _currentTab != 1,
                  child: _buildFeedListView(),
                ),
                // Tab 2: 公告（保持状态）
                Offstage(
                  offstage: _currentTab != 2,
                  child: const SingleChildScrollView(
                    child: AnnouncementList(),
                  ),
                ),
                // Tab 3: 新闻（保持状态）
                Offstage(
                  offstage: _currentTab != 3,
                  child: const SingleChildScrollView(
                    child: NewsList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedListView() {
    if (_isLoading && _feedList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _feedList.isEmpty) {
      // 获取主题颜色
      final textTheme = context.textTheme;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 16,
                color: textTheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: textTheme.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadFeedList(refresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 过滤被屏蔽用户和不感兴趣的帖子
    final blockedUserIds = _blockedUsersService.getBlockedUserIds();
    final notInterestedIds = _notInterestedService.getNotInterestedIds();
    final filteredList = _feedList.where((post) {
      // 过滤被屏蔽的用户（优先使用 profile.userId，fallback 到 userId）
      final userId = post.profile?.userId ?? post.userId;
      if (userId != null && userId != 0 && blockedUserIds.contains(userId)) {
        return false;
      }
      // 过滤不感兴趣的帖子
      if (notInterestedIds.contains(post.id)) {
        return false;
      }
      return true;
    }).toList();

    if (filteredList.isEmpty) {
      // 根据不同的标签显示不同的空状态提示
      String emptyTitle;
      String? emptyDescription;

      switch (_currentTab) {
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

      return EmptyState.noContent(
        title: emptyTitle,
        description: emptyDescription,
        actionText: '刷新',
        onAction: () => _loadFeedList(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadFeedList(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: filteredList.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = filteredList[index];

          return FeedItem(
            key: ValueKey('feed_item_${post.id}'), // 添加key，确保组件正确对应
            postId: post.id,
            profile: post.profile!, // 使用 profile 传递用户信息
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
            onLikeChanged: (isLiked, newLikeCount) {
              // 点赞状态变化回调：同步更新所有tab缓存中相同postId的状态
              setState(() {
                // 更新当前列表中的帖子
                final currentIndex = _feedList.indexWhere((p) => p.id == post.id);
                if (currentIndex != -1) {
                  _feedList[currentIndex] = _feedList[currentIndex].copyWith(
                    isLiked: isLiked,
                    likeCount: newLikeCount,
                  );
                }

                // 同步更新其他tab缓存中的相同帖子（跳过当前tab，避免重复更新）
                _tabDataCache.forEach((tabIndex, cachedList) {
                  if (tabIndex == _currentTab) return; // 跳过当前tab

                  final cachedIndex = cachedList.indexWhere((p) => p.id == post.id);
                  if (cachedIndex != -1) {
                    // 创建新的List，避免修改原有引用
                    final updatedList = List<FeedPost>.from(cachedList);
                    updatedList[cachedIndex] = updatedList[cachedIndex].copyWith(
                      isLiked: isLiked,
                      likeCount: newLikeCount,
                    );
                    _tabDataCache[tabIndex] = updatedList;
                  }
                });

                // 保存更新后的列表到当前tab缓存（深拷贝）
                _tabDataCache[_currentTab] = List<FeedPost>.from(_feedList);
              });
            },
            onRemove: () {
              // 列表页删除回调：从列表中移除该帖子
              setState(() {
                _feedList.removeWhere((p) => p.id == post.id);
                // 更新当前tab的缓存（深拷贝）
                _tabDataCache[_currentTab] = List<FeedPost>.from(_feedList);
              });
            },
          );
        },
      ),
    );
  }
}
