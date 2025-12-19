import 'package:flutter/material.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_post.dart';
import 'package:fastapp/di/service_locator.dart';

/// Feed 控制器 - 管理信息流的状态和数据
class FeedController extends ChangeNotifier {
  final FeedRepository _feedRepository = getIt<FeedRepository>();

  int _currentTab = 0;

  // 为每个tab缓存数据
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

  // Getters
  int get currentTab => _currentTab;
  List<FeedPost> get feedList => _feedList;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// 初始化 - 加载第一页数据
  void init() {
    loadFeedList();
  }

  /// 切换标签
  void switchTab(int index) {
    // 保存当前tab的数据到缓存
    _tabDataCache[_currentTab] = _feedList;
    _tabPageCache[_currentTab] = _currentPage;
    _tabHasMoreCache[_currentTab] = _hasMore;

    // 切换到新tab
    _currentTab = index;

    // 从缓存恢复新tab的数据
    if (_tabDataCache.containsKey(index)) {
      _feedList = _tabDataCache[index]!;
      _currentPage = _tabPageCache[index] ?? 1;
      _hasMore = _tabHasMoreCache[index] ?? true;
      notifyListeners();
    } else {
      // 新tab没有缓存，清空并加载
      _feedList = [];
      _currentPage = 1;
      _hasMore = true;
      loadFeedList(refresh: true);
    }
  }

  /// 加载信息流列表
  Future<void> loadFeedList({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = _feedList.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<FeedPost> newList;

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

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

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

      _feedList.addAll(newList);
      _hasMore = newList.length >= _pageSize;
      _isLoadingMore = false;

      // 更新当前tab的缓存
      _tabDataCache[_currentTab] = _feedList;
      _tabPageCache[_currentTab] = _currentPage;
      _tabHasMoreCache[_currentTab] = _hasMore;

      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _currentPage--;
      notifyListeners();
    }
  }

  /// 插入新帖子到列表顶部
  void insertNewPost(FeedPost post) {
    _feedList.insert(0, post);
    // 更新当前tab的缓存
    _tabDataCache[_currentTab] = _feedList;
    notifyListeners();
  }

  /// 从列表中移除帖子
  void removePost(int postId) {
    _feedList.removeWhere((post) => post.id == postId);
    // 更新当前tab的缓存
    _tabDataCache[_currentTab] = _feedList;
    notifyListeners();
  }

  @override
  void dispose() {
    _tabDataCache.clear();
    _tabPageCache.clear();
    _tabHasMoreCache.clear();
    super.dispose();
  }
}
