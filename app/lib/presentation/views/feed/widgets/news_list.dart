import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/feed/widgets/news_item.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_article.dart';
import 'package:fastapp/di/service_locator.dart';

/// 新闻列表组件
///
/// 显示按日期分组的新闻列表，带时间线样式
class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();

  List<FeedArticle> _newsList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNewsList();
  }

  Future<void> _loadNewsList() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newsList = await _feedRepository.getNewsList(
        page: 1,
        pageSize: 20,
      );

      setState(() {
        _newsList = newsList;
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
    if (_isLoading && _newsList.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32.0),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _newsList.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                onPressed: _loadNewsList,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_newsList.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            '暂无新闻',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildGroupedNewsList(),
      ),
    );
  }

  /// 构建按日期分组的新闻列表
  List<Widget> _buildGroupedNewsList() {
    // 按日期分组
    final Map<String, List<FeedArticle>> groupedNews = {};

    for (final news in _newsList) {
      final date = news.getFormattedDate();
      if (!groupedNews.containsKey(date)) {
        groupedNews[date] = [];
      }
      groupedNews[date]!.add(news);
    }

    // 构建UI
    final List<Widget> widgets = [];

    groupedNews.forEach((date, newsList) {
      // 添加日期标题
      widgets.add(_buildDateHeader(date));

      // 添加该日期下的新闻列表
      for (int i = 0; i < newsList.length; i++) {
        final news = newsList[i];
        final isLast = i == newsList.length - 1 &&
                       date == groupedNews.keys.last;

        widgets.add(
          NewsItem(
            time: news.getTimeOnly(),
            title: news.title,
            profile: news.profile,
            isLast: isLast,
          ),
        );
      }
    });

    return widgets;
  }

  Widget _buildDateHeader(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(2),
            ),
            transform: Matrix4.rotationZ(0.785398), // 45度旋转，形成菱形
          ),
          const SizedBox(width: 12),
          Text(
            date,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
