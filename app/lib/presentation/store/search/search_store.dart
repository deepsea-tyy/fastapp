import 'package:mobx/mobx.dart';
import 'package:fastapp/data/network/apis/search/search_api.dart';
import 'package:fastapp/data/network/models/search_keyword.dart';
import 'package:fastapp/data/network/models/search_index_item.dart';
import 'package:fastapp/core/data/network/dio/dio_client.dart';

part 'search_store.g.dart';

class SearchStore = _SearchStore with _$SearchStore;

abstract class _SearchStore with Store {
  final DioClient _dioClient;
  late final SearchApi _searchApi;

  _SearchStore(this._dioClient) {
    _searchApi = SearchApi(_dioClient);
  }

  // 热门关键词列表
  @observable
  ObservableList<SearchKeyword> hotKeywords = ObservableList<SearchKeyword>();

  // 搜索排行榜列表
  @observable
  ObservableList<SearchIndexItem> rankingList = ObservableList<SearchIndexItem>();

  // 第一条热门关键词（用于 TopBar）
  @computed
  SearchKeyword? get topHotKeyword {
    return hotKeywords.isNotEmpty ? hotKeywords.first : null;
  }

  // 加载状态
  @observable
  bool isLoading = false;

  // 最后更新时间
  @observable
  DateTime? lastUpdateTime;

  /// 加载热门关键词
  @action
  Future<void> loadHotKeywords({int limit = 10}) async {
    try {
      final response = await _searchApi.hotKeywords(limit: limit);
      final list = (response['list'] as List?) ?? [];

      hotKeywords.clear();
      hotKeywords.addAll(
        list
            .map((item) => SearchKeyword.fromJson(item as Map<String, dynamic>))
            .where((keyword) => keyword.keyword.trim().isNotEmpty),
      );

      lastUpdateTime = DateTime.now();
    } catch (e) {
      // 静默失败，保留现有数据
    }
  }

  /// 加载搜索排行榜
  @action
  Future<void> loadRanking() async {
    try {
      final response = await _searchApi.ranking();
      final list = (response['list'] as List?) ?? [];

      rankingList.clear();
      rankingList.addAll(
        list.map((item) => SearchIndexItem.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      // 静默失败，保留现有数据
    }
  }

  /// 刷新热门关键词和排行榜
  @action
  Future<void> refresh() async {
    if (isLoading) return;

    isLoading = true;
    try {
      await Future.wait([
        loadHotKeywords(),
        loadRanking(),
      ]);
    } finally {
      isLoading = false;
    }
  }

  /// 检查是否需要刷新（超过5分钟未更新）
  @computed
  bool get needsRefresh {
    if (lastUpdateTime == null) return true;
    final difference = DateTime.now().difference(lastUpdateTime!);
    return difference.inMinutes >= 5;
  }

  /// 自动刷新（如果需要）
  @action
  Future<void> autoRefresh() async {
    if (needsRefresh) {
      await refresh();
    }
  }

  void dispose() {
    // 清理资源
  }
}
