import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/feed/following_page.dart';
import 'package:fastapp/presentation/views/feed/feed_profile.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/utils/image_utils.dart';

/// 关注源列表组件
class SourcesBar extends StatefulWidget {
  const SourcesBar({super.key});

  @override
  State<SourcesBar> createState() => _SourcesBarState();
}

class _SourcesBarState extends State<SourcesBar> {
  final _feedRepository = getIt<FeedRepository>();
  List<Map<String, dynamic>> _followingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowingList();
  }

  Future<void> _loadFollowingList() async {
    setState(() => _isLoading = true);
    try {
      _followingUsers = await _feedRepository.getFollowingUserList(page: 1, pageSize: 5);
    } catch (e) {
      debugPrint('加载关注列表失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: _isLoading
          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._followingUsers.map((item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildItem(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(
                              userId: item['follow_user_id'] as int? ??
                                      item['user_id'] as int? ?? 0,
                            ),
                          ),
                        ),
                        avatar: item['avatar'] as String? ?? '',
                        label: item['nickname'] as String? ?? '用户',
                      ),
                    )),
                _buildItem(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FollowingPage()),
                  ),
                  icon: Icons.more_horiz,
                  label: '关注',
                ),
                const Spacer(),
              ],
            ),
    );
  }

  Widget _buildItem({
    required VoidCallback onTap,
    String? avatar,
    IconData? icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: icon != null
                  ? Icon(icon, color: Colors.grey.shade700, size: 20)
                  : _buildAvatarContent(avatar!, label),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black87, height: 1.1),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(String avatar, String label) {
    if (avatar.isEmpty || !ImageUtils.isValidImagePath(avatar)) {
      return Center(
        child: Text(
          label.isNotEmpty ? label[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        ImageUtils.formatSingleImagePath(avatar),
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            label.isNotEmpty ? label[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
