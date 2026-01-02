import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/feed/widgets/announcement_tabs.dart';
import 'package:fastapp/presentation/views/feed/widgets/announcement_item.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_article.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/core/theme/app_theme_extension.dart';

/// 公告列表组件
///
/// 包含子标签栏和公告列表
class AnnouncementList extends StatefulWidget {
  const AnnouncementList({super.key});

  @override
  State<AnnouncementList> createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();

  int _currentSubTab = 0;
  List<FeedArticle> _announcementList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnnouncementList();
  }

  Future<void> _loadAnnouncementList() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final announcementList = await _feedRepository.getAnnouncementList(
        page: 1,
        pageSize: 20,
      );

      setState(() {
        _announcementList = announcementList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundTheme = context.backgroundTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.of(context).size.height,
          ),
          color: backgroundTheme.card, // 使用卡片背景色（白色）
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    // 获取主题颜色
    final textTheme = context.textTheme;

    if (_isLoading && _announcementList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _announcementList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                onPressed: _loadAnnouncementList,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_announcementList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            '暂无公告',
            style: TextStyle(
              fontSize: 16,
              color: textTheme.hint,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildAnnouncementList(),
    );
  }

  List<Widget> _buildAnnouncementList() {
    // 暂时不根据子标签筛选，直接显示所有公告
    // TODO: 如果服务端支持分类筛选，可以在这里根据_currentSubTab进行筛选
    final announcements = _announcementList;

    return announcements.asMap().entries.map((entry) {
      final index = entry.key;
      final announcement = entry.value;
      final isLast = index == announcements.length - 1;

      return Column(
        children: [
          AnnouncementItem(
            id: announcement.id,
            type: announcement.type ?? 3, // 使用文章类型，默认为3（公告）
            title: announcement.title,
            timestamp: announcement.getFormattedTime(),
            profile: announcement.profile,
          ),
          if (!isLast) const Divider(height: 1, indent: 52),
        ],
      );
    }).toList();
  }
}
