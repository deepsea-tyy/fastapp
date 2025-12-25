import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../common/search_input_widget.dart';
import 'package:fastapp/presentation/store/search/search_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:fastapp/data/network/apis/feed/feed_api.dart';
import 'package:fastapp/core/data/network/dio/dio_client.dart';

/// 搜索结果页面
class SearchResultScreen extends StatefulWidget {
  final String? initialKeyword;

  const SearchResultScreen({super.key, this.initialKeyword});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final MarketStore _marketStore;
  late final MarketDataStore _marketDataStore;
  late final FeedApi _feedApi;

  String _selectedCategory = '所有';
  final List<String> _categories = [
    '所有',
    '现货',
    '合约',
    'Ai交易',
    '理财',
    '公告',
    '广场',
    '其他'
  ];

  List<_SearchGroup> _searchResults = [];
  bool _isLoading = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _marketStore = getIt<MarketStore>();
    _marketDataStore = getIt<MarketDataStore>();
    _feedApi = FeedApi(getIt<DioClient>());

    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      _controller.text = widget.initialKeyword!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialKeyword!);
      });
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String keyword) async {
    final query = keyword.trim();
    if (query.isEmpty && _selectedCategory == '所有') {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      // 根据不同的分类进行搜索
      if (_selectedCategory == '公告') {
        await _searchAnnouncements();
      } else if (_selectedCategory == '广场') {
        await _searchFeedPosts();
      } else if (_selectedCategory == '其他') {
        await _searchArticles();
      } else {
        await _searchMarket(query.toUpperCase());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 搜索市场交易对
  Future<void> _searchMarket(String query) async {
    final spotResults = <_SearchResultItem>[];
    final futuresResults = <_SearchResultItem>[];

    // 辅助函数：查找 ticker 数据
    TickerData? findTicker(String symbol) {
      try {
        return _marketStore.tickerList.firstWhere(
          (t) => t.symbol == symbol || t.symbol.replaceAll('/', '') == symbol,
        );
      } catch (_) {
        return null;
      }
    }

    // 辅助函数：判断是否匹配
    bool matches(String text) => text.toUpperCase().contains(query);

    // 搜索现货交易对
    if (_selectedCategory == '所有' || _selectedCategory == '现货') {
      for (final pair in _marketDataStore.allSpotPairs) {
        if (matches(pair.symbol) || matches(pair.baseCurrencySymbol) || matches(pair.quoteCurrencySymbol)) {
          final ticker = findTicker(pair.symbol);
          final currency = _marketDataStore.getCurrency(pair.baseCurrencySymbol);
          final logo = currency?.logo;
          final logoUrl = logo != null && logo.isNotEmpty
              ? ImageUtils.formatSingleImagePath(logo)
              : null;

          spotResults.add(_SearchResultItem(
            type: 'market',
            symbol: pair.baseCurrencySymbol,
            quoteCurrency: pair.quoteCurrencySymbol,
            leverage: null,
            imageUrl: logoUrl,
            price: ticker?.lastPrice.toString() ?? '',
            changePercent: ticker?.changePercent ?? 0,
            ticker: ticker,
            isFutures: false,
          ));
        }
      }
    }

    // 搜索合约交易对
    if (_selectedCategory == '所有' || _selectedCategory == '合约') {
      for (final pair in _marketDataStore.allFutures) {
        if (matches(pair.symbol) || matches(pair.baseCurrencySymbol) || matches(pair.quoteCurrencySymbol)) {
          final ticker = findTicker(pair.symbol);
          final currency = _marketDataStore.getCurrency(pair.baseCurrencySymbol);
          final logo = currency?.logo;
          final logoUrl = logo != null && logo.isNotEmpty
              ? ImageUtils.formatSingleImagePath(logo)
              : null;

          futuresResults.add(_SearchResultItem(
            type: 'market',
            symbol: pair.baseCurrencySymbol,
            quoteCurrency: pair.quoteCurrencySymbol,
            leverage: '5x',
            imageUrl: logoUrl,
            price: ticker?.lastPrice.toString() ?? '',
            changePercent: ticker?.changePercent ?? 0,
            ticker: ticker,
            isFutures: true,
          ));
        }
      }
    }

    final groups = <_SearchGroup>[];
    if (spotResults.isNotEmpty) {
      groups.add(_SearchGroup(title: '现货', items: spotResults));
    }
    if (futuresResults.isNotEmpty) {
      groups.add(_SearchGroup(title: '合约', items: futuresResults));
    }

    setState(() => _searchResults = groups);
  }

  // 搜索公告
  Future<void> _searchAnnouncements() async {
    try {
      final keyword = _controller.text.trim();
      final response = await _feedApi.getAnnouncementList(
        keyword: keyword.isNotEmpty ? keyword : null,
        page: _currentPage,
        pageSize: 20,
      );
      final list = (response['list'] as List?) ?? [];

      final items = list.map((item) => _SearchResultItem(
        type: 'announcement',
        id: item['id'],
        title: item['title'] ?? '',
        content: item['brief'] ?? item['content'] ?? '',
        imageUrl: _getCoverImage(item['cover']),
        createdAt: item['created_at'],
        viewCount: item['view_count'] ?? 0,
      )).toList();

      setState(() {
        _searchResults = items.isNotEmpty
            ? [_SearchGroup(title: '公告', items: items)]
            : [];
      });
    } catch (e) {
      print('搜索公告失败: $e');
      setState(() => _searchResults = []);
    }
  }

  // 搜索广场帖子
  Future<void> _searchFeedPosts() async {
    try {
      final keyword = _controller.text.trim();
      final response = await _feedApi.getFeedList(
        filter: 'latest',
        keyword: keyword.isNotEmpty ? keyword : null,
        page: _currentPage,
        pageSize: 20,
      );
      final list = (response['list'] as List?) ?? [];

      final items = list.map((item) => _SearchResultItem(
        type: 'feed',
        id: item['id'],
        title: item['title'] ?? '',
        content: item['content'] ?? '',
        imageUrl: _getFirstImage(item['images']),
        profile: item['profile'],
        createdAt: item['created_at'],
        likeCount: item['like_count'] ?? 0,
        commentCount: item['comment_count'] ?? 0,
      )).toList();

      setState(() {
        _searchResults = items.isNotEmpty
            ? [_SearchGroup(title: '广场', items: items)]
            : [];
      });
    } catch (e) {
      print('搜索广场帖子失败: $e');
      setState(() => _searchResults = []);
    }
  }

  // 搜索文章
  Future<void> _searchArticles() async {
    try {
      final keyword = _controller.text.trim();
      final response = await _feedApi.getArticleList(
        keyword: keyword.isNotEmpty ? keyword : null,
        page: _currentPage,
        pageSize: 20,
      );
      final list = (response['list'] as List?) ?? [];

      final items = list.map((item) => _SearchResultItem(
        type: 'article',
        id: item['id'],
        title: item['title'] ?? '',
        content: item['brief'] ?? item['content'] ?? '',
        imageUrl: _getCoverImage(item['cover']),
        createdAt: item['created_at'],
        viewCount: item['view_count'] ?? 0,
      )).toList();

      setState(() {
        _searchResults = items.isNotEmpty
            ? [_SearchGroup(title: '其他', items: items)]
            : [];
      });
    } catch (e) {
      print('搜索文章失败: $e');
      setState(() => _searchResults = []);
    }
  }

  String? _getCoverImage(dynamic cover) {
    if (cover == null) return null;
    if (cover is String && cover.isNotEmpty) {
      return ImageUtils.formatSingleImagePath(cover);
    }
    if (cover is List && cover.isNotEmpty) {
      return ImageUtils.formatSingleImagePath(cover.first.toString());
    }
    return null;
  }

  String? _getFirstImage(dynamic images) {
    if (images == null) return null;
    if (images is List && images.isNotEmpty) {
      return ImageUtils.formatSingleImagePath(images.first.toString());
    }
    return null;
  }

  void _handleItemTap(_SearchResultItem item) {
    if (item.type == 'market' && item.ticker != null) {
      // 获取最新的 ticker 数据
      final symbol = item.ticker!.symbol;
      TickerData? currentTicker;
      try {
        currentTicker = _marketStore.tickerList.firstWhere(
          (t) => t.symbol == symbol || t.symbol.replaceAll('/', '') == symbol,
        );
      } catch (_) {
        currentTicker = item.ticker;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarketDetailScreen(
            ticker: currentTicker!,
            isFutures: item.isFutures ?? false,
          ),
        ),
      );
    } else if (item.type == 'announcement' || item.type == 'article') {
      // TODO: 导航到文章详情页
      print('查看文章详情: ${item.id}');
    } else if (item.type == 'feed') {
      // TODO: 导航到帖子详情页
      print('查看帖子详情: ${item.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: '搜索',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      onChanged: _performSearch,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _searchResults = []);
                      },
                      child: Icon(Icons.clear, size: 18, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (_, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              _performSearch(_controller.text);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  )
                else
                  const SizedBox(height: 3),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          _controller.text.isEmpty && !['公告', '广场', '其他'].contains(_selectedCategory) ? '' : '暂无结果',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (_, groupIndex) {
        final group = _searchResults[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            ...group.items.map((item) => _buildResultItem(item)),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(_SearchResultItem item) {
    if (item.type == 'market') {
      return _buildMarketItem(item);
    } else if (item.type == 'feed') {
      return _buildFeedItem(item);
    } else {
      return _buildArticleItem(item);
    }
  }

  Widget _buildMarketItem(_SearchResultItem item) {
    return InkWell(
      onTap: () => _handleItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            if (item.imageUrl != null)
              ClipOval(
                child: Image.network(
                  item.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.currency_bitcoin, size: 20, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_bitcoin, size: 20, color: Colors.grey),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    item.symbol ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${item.quoteCurrency ?? ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (item.leverage != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.leverage!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Observer(
              builder: (_) {
                // 实时获取最新的 ticker 数据
                final symbol = item.ticker?.symbol;
                TickerData? currentTicker;
                if (symbol != null) {
                  try {
                    currentTicker = _marketStore.tickerList.firstWhere(
                      (t) => t.symbol == symbol || t.symbol.replaceAll('/', '') == symbol,
                    );
                  } catch (_) {
                    currentTicker = item.ticker;
                  }
                } else {
                  currentTicker = item.ticker;
                }

                final hasValidPrice = currentTicker != null &&
                    !currentTicker.lastPrice.isNaN &&
                    !currentTicker.lastPrice.isInfinite &&
                    currentTicker.lastPrice > 0;

                if (!hasValidPrice) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentTicker.lastPrice.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${currentTicker.changePercent >= 0 ? '+' : ''}${currentTicker.changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentTicker.changePercent >= 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(_SearchResultItem item) {
    final profile = item.profile;
    final username = profile?['nickname'] ?? '未知用户';
    final avatar = profile?['avatar'] ?? '';

    return InkWell(
      onTap: () => _handleItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户头像
            ClipOval(
              child: avatar.isNotEmpty
                  ? Image.network(
                      ImageUtils.formatSingleImagePath(avatar),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 20, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            // 内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.title?.isNotEmpty ?? false) ...[
                    Text(
                      item.title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    item.content ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${item.likeCount ?? 0}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${item.commentCount ?? 0}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 右侧图片（如果有）
            if (item.imageUrl != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(_SearchResultItem item) {
    return InkWell(
      onTap: () => _handleItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.content ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${item.viewCount ?? 0}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      if (item.createdAt != null) ...[
                        const SizedBox(width: 16),
                        Text(
                          _formatTime(item.createdAt!),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 右侧封面图（如果有）
            if (item.imageUrl != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 80,
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) return '刚刚';
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      if (diff.inDays < 7) return '${diff.inDays}天前';

      return '${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return dateTimeStr;
    }
  }
}

class _SearchGroup {
  final String title;
  final List<_SearchResultItem> items;

  _SearchGroup({required this.title, required this.items});
}

class _SearchResultItem {
  final String type; // 'market', 'feed', 'announcement', 'article'
  final int? id;
  final String? symbol;
  final String? quoteCurrency;
  final String? leverage;
  final String? imageUrl;
  final String? price;
  final double? changePercent;
  final TickerData? ticker;
  final bool? isFutures;
  final String? title;
  final String? content;
  final Map<String, dynamic>? profile;
  final String? createdAt;
  final int? likeCount;
  final int? commentCount;
  final int? viewCount;

  _SearchResultItem({
    required this.type,
    this.id,
    this.symbol,
    this.quoteCurrency,
    this.leverage,
    this.imageUrl,
    this.price,
    this.changePercent,
    this.ticker,
    this.isFutures,
    this.title,
    this.content,
    this.profile,
    this.createdAt,
    this.likeCount,
    this.commentCount,
    this.viewCount,
  });
}
