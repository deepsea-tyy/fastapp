import 'package:shared_preferences/shared_preferences.dart';

/// 不感兴趣内容服务
///
/// 管理本地不感兴趣的帖子/文章ID列表，用于信息流过滤
class NotInterestedService {
  final SharedPreferences _prefs;
  static const String _notInterestedKey = 'not_interested_posts';

  NotInterestedService(this._prefs);

  /// 获取所有不感兴趣的内容ID列表
  List<int> getNotInterestedIds() {
    final stringList = _prefs.getStringList(_notInterestedKey) ?? [];
    return stringList.map((id) => int.parse(id)).toList();
  }

  /// 检查内容是否被标记为不感兴趣
  bool isNotInterested(int postId) {
    final notInterestedIds = getNotInterestedIds();
    return notInterestedIds.contains(postId);
  }

  /// 标记为不感兴趣
  Future<bool> markAsNotInterested(int postId) async {
    final notInterestedIds = getNotInterestedIds();
    if (!notInterestedIds.contains(postId)) {
      notInterestedIds.add(postId);
      return await _saveNotInterestedIds(notInterestedIds);
    }
    return true;
  }

  /// 取消标记不感兴趣
  Future<bool> unmarkAsNotInterested(int postId) async {
    final notInterestedIds = getNotInterestedIds();
    notInterestedIds.remove(postId);
    return await _saveNotInterestedIds(notInterestedIds);
  }

  /// 保存不感兴趣ID列表
  Future<bool> _saveNotInterestedIds(List<int> postIds) async {
    final stringList = postIds.map((id) => id.toString()).toList();
    return await _prefs.setStringList(_notInterestedKey, stringList);
  }

  /// 清除所有不感兴趣标记
  Future<bool> clearAll() async {
    return await _prefs.remove(_notInterestedKey);
  }

  /// 获取不感兴趣内容数量
  int getNotInterestedCount() {
    return getNotInterestedIds().length;
  }
}
