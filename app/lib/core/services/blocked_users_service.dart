import 'package:shared_preferences/shared_preferences.dart';

/// 屏蔽用户服务
///
/// 管理本地屏蔽用户列表，用于信息流过滤
class BlockedUsersService {
  final SharedPreferences _prefs;
  static const String _blockedUsersKey = 'blocked_users';

  BlockedUsersService(this._prefs);

  /// 获取所有被屏蔽的用户ID列表
  List<int> getBlockedUserIds() {
    final stringList = _prefs.getStringList(_blockedUsersKey) ?? [];
    return stringList.map((id) => int.parse(id)).toList();
  }

  /// 检查用户是否被屏蔽
  bool isUserBlocked(int userId) {
    final blockedUsers = getBlockedUserIds();
    return blockedUsers.contains(userId);
  }

  /// 屏蔽用户
  Future<bool> blockUser(int userId) async {
    final blockedUsers = getBlockedUserIds();
    if (!blockedUsers.contains(userId)) {
      blockedUsers.add(userId);
      return await _saveBlockedUsers(blockedUsers);
    }
    return true;
  }

  /// 取消屏蔽用户
  Future<bool> unblockUser(int userId) async {
    final blockedUsers = getBlockedUserIds();
    blockedUsers.remove(userId);
    return await _saveBlockedUsers(blockedUsers);
  }

  /// 保存屏蔽用户列表
  Future<bool> _saveBlockedUsers(List<int> userIds) async {
    final stringList = userIds.map((id) => id.toString()).toList();
    return await _prefs.setStringList(_blockedUsersKey, stringList);
  }

  /// 清除所有屏蔽用户
  Future<bool> clearAllBlockedUsers() async {
    return await _prefs.remove(_blockedUsersKey);
  }

  /// 获取屏蔽用户数量
  int getBlockedUsersCount() {
    return getBlockedUserIds().length;
  }
}
