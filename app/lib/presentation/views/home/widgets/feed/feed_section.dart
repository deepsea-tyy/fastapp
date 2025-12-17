import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_tabs.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_item.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/sources_bar.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/announcement_list.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/news_list.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_post.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/core/widgets/common_empty_state.dart';
import 'package:fastapp/utils/image_utils.dart';

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

        // 更新当前tab的缓存
        _tabDataCache[_currentTab] = _feedList;
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

        // 更新当前tab的缓存
        _tabDataCache[_currentTab] = _feedList;
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

    return Container(
      color: Colors.grey.shade200,
      height: feedHeight,
      child: Column(
        children: [
          FeedTabs(
            initialIndex: _currentTab,
            onTabChanged: (index) {
              setState(() {
                // 保存当前tab的数据到缓存
                _tabDataCache[_currentTab] = _feedList;
                _tabPageCache[_currentTab] = _currentPage;
                _tabHasMoreCache[_currentTab] = _hasMore;

                // 切换到新tab
                _currentTab = index;

                // 从缓存恢复新tab的数据，如果有的话
                if (_tabDataCache.containsKey(index)) {
                  _feedList = _tabDataCache[index]!;
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
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

    if (_feedList.isEmpty) {
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

      return CommonEmptyState.noContent(
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
        itemCount: _feedList.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _feedList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = _feedList[index];
          // 优先使用 profile 数据，否则使用平铺字段
          final username = post.profile?.displayNickname ?? post.username ?? '用户${post.userId}';
          final avatar = post.profile?.displayAvatar ?? post.avatar ?? '';

          // 转换图片列表为 Widget（使用 formattedImages getter）
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
            userId: post.userId ?? 0,
            username: username,
            avatarAsset: avatar,
            time: post.getFormattedTime(),
            title: post.title,
            content: post.content ?? '',
            media: mediaWidgets,
            isVerified: post.isVerified ?? false,
            commentCount: post.commentCount,
            likeCount: post.likeCount,
            repostCount: post.quoteCount ?? 0,  // 使用quoteCount作为repostCount
            shareCount: post.shareCount ?? 0,
            isLiked: post.isLiked ?? false,
            menuIcon: Icons.more_horiz,
          );
        },
      ),
    );
  }
}
