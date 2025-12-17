import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/feed/following_page.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/utils/image_utils.dart';

/// 关注源列表组件
///
/// 横向滚动显示已关注的源和"关注"按钮
class SourcesBar extends StatefulWidget {
  const SourcesBar({super.key});

  @override
  State<SourcesBar> createState() => _SourcesBarState();
}

class _SourcesBarState extends State<SourcesBar> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();
  List<Map<String, dynamic>> _followingUsers = [];
  bool _isLoading = true;

  static const double _avatarSize = 30.0;
  static const double _itemSpacing = 0.0;
  static const double _textWidth = 60.0;
  static const int _pageSize = 3;
  static const double _horizontalPadding = 2.0;

  @override
  void initState() {
    super.initState();
    _loadFollowingList();
  }

  /// 加载关注列表
  Future<void> _loadFollowingList() async {
    setState(() => _isLoading = true);
    try {
      final followingUsers = await _feedRepository.getFollowingUserList(
        page: 1,
        pageSize: _pageSize,
      );
      setState(() {
        _followingUsers = followingUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('加载关注列表失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _isLoading
          ? const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.only(left: _horizontalPadding),
              child: Row(
                children: [
                  ..._followingUsers.map((item) {
                    final userId = item['follow_user_id'] as int? ?? item['user_id'] as int? ?? 0;
                    final nickname = item['nickname'] as String? ?? '用户$userId';
                    final avatar = item['avatar'] as String? ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(right: _itemSpacing),
                      child: _buildSourceItem(nickname, avatar),
                    );
                  }),
                  const SizedBox(width: 4),
                  _buildFollowButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSourceItem(String name, String avatar) {
    final avatarUrl = avatar.isNotEmpty && ImageUtils.isValidImagePath(avatar)
        ? ImageUtils.formatSingleImagePath(avatar)
        : null;
    final firstChar = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(avatarUrl, firstChar),
        const SizedBox(height: 6),
        SizedBox(
          width: _textWidth,
          child: Text(
            name,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl, String firstChar) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: avatarUrl != null
          ? ClipOval(
              child: Image.network(
                avatarUrl,
                width: _avatarSize,
                height: _avatarSize,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(firstChar),
              ),
            )
          : _buildDefaultAvatar(firstChar),
    );
  }

  Widget _buildDefaultAvatar(String firstChar) {
    return Center(
      child: Text(
        firstChar,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FollowingPage()),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _avatarSize,
            height: _avatarSize,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, color: Colors.black87, size: 20),
          ),
          const SizedBox(height: 6),
          const Text(
            '关注',
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
