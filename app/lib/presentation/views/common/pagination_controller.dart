import 'package:flutter/material.dart';

/// 分页加载控制器
/// 提供通用的分页加载功能
class PaginationController<T> {
  /// 当前页码
  int _currentPage = 1;
  
  /// 每页数据量
  final int pageSize;
  
  /// 是否正在加载
  bool _isLoading = false;
  
  /// 是否还有更多数据
  bool _hasMore = true;
  
  /// 数据列表
  List<T> _dataList = [];
  
  /// 滚动控制器
  ScrollController? _scrollController;
  
  /// setState 回调
  final VoidCallback? onStateChanged;
  
  /// mounted 检查回调
  final bool Function()? isMounted;
  
  /// 加载数据回调
  final Future<List<T>> Function(int page, int pageSize) loadDataCallback;
  
  PaginationController({
    this.pageSize = 20,
    this.onStateChanged,
    this.isMounted,
    required this.loadDataCallback,
  });
  
  /// 获取当前页码
  int get currentPage => _currentPage;
  
  /// 获取是否正在加载
  bool get isLoading => _isLoading;
  
  /// 获取是否还有更多数据
  bool get hasMore => _hasMore;
  
  /// 获取数据列表
  List<T> get dataList => _dataList;
  
  bool _listenerAdded = false;
  
  /// 获取滚动控制器
  ScrollController get scrollController {
    if (_scrollController == null) {
      _scrollController = ScrollController();
    }
    // 确保监听器只添加一次
    if (!_listenerAdded) {
      _scrollController!.addListener(_onScroll);
      _listenerAdded = true;
    }
    return _scrollController!;
  }
  
  /// 初始化分页
  void init() {
    _currentPage = 1;
    _hasMore = true;
    _dataList = [];
    // 如果 scrollController 已创建，确保监听器已添加
    if (_scrollController != null && !_listenerAdded) {
      _scrollController!.addListener(_onScroll);
      _listenerAdded = true;
    }
  }
  
  /// 滚动监听
  void _onScroll() {
    if (!_scrollController!.hasClients) return;
    
    // 如果正在加载中，不触发新的加载请求
    if (_isLoading) return;
    
    final position = _scrollController!.position;
    // 当滚动到距离底部200像素时，触发加载更多
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadMore();
    }
  }
  
  /// 刷新数据
  Future<void> refresh() async {
    // 如果正在加载中，直接返回，避免重复请求
    if (_isLoading) return;
    
    _currentPage = 1;
    _hasMore = true;
    await loadMore();
  }
  
  /// 加载更多数据
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    onStateChanged?.call();
    
    try {
      final newData = await loadDataCallback(_currentPage, pageSize);
      
      if (isMounted?.call() ?? true) {
        if (_currentPage == 1) {
          _dataList = newData;
        } else {
          _dataList.addAll(newData);
        }
        
        // 如果返回的数据量为空或小于每页数量，说明没有更多数据了
        _hasMore = newData.isNotEmpty && newData.length >= pageSize;
        
        if (_hasMore) {
          _currentPage++;
        }
        
        _isLoading = false;
        onStateChanged?.call();
      }
    } catch (e) {
      if (isMounted?.call() ?? true) {
        _hasMore = false;
        _isLoading = false;
        onStateChanged?.call();
      }
      rethrow;
    }
  }
  
  /// 清理资源
  void dispose() {
    if (_scrollController != null && _listenerAdded) {
      _scrollController!.removeListener(_onScroll);
      _listenerAdded = false;
    }
    _scrollController?.dispose();
    _scrollController = null;
  }
  
  /// 构建加载更多指示器
  Widget buildLoadMoreIndicator() {
    if (!_isLoading && !_hasMore && _dataList.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            '暂无更多数据',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}


