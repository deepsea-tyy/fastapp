import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/search_result_screen.dart';

/// 通用搜索结果项模型
class SearchResultItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Map<String, dynamic>? extra;

  const SearchResultItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.extra,
  });
}

/// 通用搜索输入组件
///
/// 支持三种模式：
/// 1. 搜索模式：提供 onSearch 回调，支持输入和搜索
/// 2. 跳转模式：提供 onTap 回调，点击后跳转到搜索页面
/// 3. 带返回按钮模式：设置 showBackButton = true，显示返回按钮样式
class SearchInputWidget extends StatefulWidget {
  final String? hintText;
  final IconData? prefixIcon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Future<List<SearchResultItem>> Function(String keyword)? onSearch;
  final void Function(SearchResultItem item)? onItemTap;
  final VoidCallback? onTap;
  final VoidCallback? onBack;
  final void Function(String keyword)? onNavigateToSearch;
  final EdgeInsets? margin;
  final double? height;
  final double? borderRadius;
  final bool autofocus;
  final bool showBackButton;

  const SearchInputWidget({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.iconColor,
    this.backgroundColor,
    this.onSearch,
    this.onItemTap,
    this.onTap,
    this.onBack,
    this.onNavigateToSearch,
    this.margin,
    this.height,
    this.borderRadius,
    this.autofocus = false,
    this.showBackButton = false,
  });

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final GlobalKey _searchBarKey = GlobalKey();

  List<SearchResultItem> _results = [];
  bool _isSearching = false;
  OverlayEntry? _overlayEntry;

  bool get _isNavigationMode => widget.onTap != null;
  bool get _hasInput => _controller.text.trim().isNotEmpty;
  bool get _shouldShowOverlay => _hasInput;
  bool _isEnglishOrNumber(String text) => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // 跳转模式下不需要任何监听器
    if (_isNavigationMode) return;

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final keyword = _controller.text.trim();

    if (keyword.isEmpty) {
      setState(() => _results = []);
      _removeOverlay();
      return;
    }

    if (_isEnglishOrNumber(keyword)) {
      _performSearch(keyword);
    } else {
      setState(() => _results = []);
    }
    _updateOverlay();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) _removeOverlay();
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _removeOverlay();

    final renderBox = _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlay(offset, size, screenSize),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildOverlay(Offset offset, Size size, Size screenSize) {
    final keyword = _controller.text.trim();

    return Stack(
      children: [
        Positioned(
          top: offset.dy + size.height,
          width: screenSize.width,
          height: screenSize.height - (offset.dy + size.height),
          child: GestureDetector(
            onTap: _closeOverlay,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: 16,
          top: offset.dy + size.height + 8,
          width: screenSize.width - 32,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: _isEnglishOrNumber(keyword)
                ? _buildEnglishSearchList()
                : _buildSearchSuggestion(),
          ),
        ),
      ],
    );
  }

  Future<void> _performSearch(String keyword) async {
    if (widget.onSearch == null) {
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await widget.onSearch!(keyword);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
      }
    }

    if (mounted) _updateOverlay();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _results = []);
    _removeOverlay();
  }

  void _handleItemTap(SearchResultItem item) {
    _closeOverlay();
    widget.onItemTap?.call(item);
  }

  void _closeOverlay() {
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _navigateToSearchResult(String keyword) {
    _closeOverlay();

    // 调用回调通知父组件（例如保存历史记录）
    widget.onNavigateToSearch?.call(keyword);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(initialKeyword: keyword),
      ),
    );
  }

  void _handleSubmit(String value) {
    var keyword = value.trim();

    // 如果输入为空但有预览关键词（不是默认的"搜索"），使用预览关键词
    if (keyword.isEmpty && _isValidHintKeyword) {
      keyword = widget.hintText!;
    }

    if (keyword.isEmpty) return;

    _isEnglishOrNumber(keyword)
        ? _navigateToSearchResult(keyword)
        : _handleItemTap(SearchResultItem(id: keyword, title: keyword));
  }

  bool get _isValidHintKeyword =>
      widget.hintText != null &&
      widget.hintText != '搜索' &&
      widget.hintText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // 带返回按钮模式
    if (widget.showBackButton) {
      return Padding(
        padding: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildBackButton(),
            const SizedBox(width: 12),
            Expanded(child: _buildSearchInput(enabled: true, withPadding: true)),
          ],
        ),
      );
    }

    // 跳转模式：返回可点击的只读搜索框
    if (_isNavigationMode) {
      return GestureDetector(
        onTap: widget.onTap,
        child: _buildSearchInput(enabled: false),
      );
    }

    // 搜索模式：返回可交互的搜索框
    return _buildSearchInput(enabled: true);
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
      onPressed: widget.onBack,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildSearchInput({required bool enabled, bool withPadding = false}) {
    final padding = withPadding
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
        : null;

    return Container(
      key: _searchBarKey,
      height: widget.height ?? 40,
      margin: widget.showBackButton ? null : (widget.margin ?? const EdgeInsets.fromLTRB(16, 16, 16, 0)),
      padding: padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
      ),
      child: Row(
        children: [
          if (!withPadding) const SizedBox(width: 12),
          Icon(
            widget.prefixIcon ?? Icons.search,
            size: 20,
            color: widget.iconColor ?? Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: enabled,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hintText ?? '搜索',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: withPadding ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              onSubmitted: enabled ? _handleSubmit : null,
            ),
          ),
          if (enabled && _isSearching)
            Padding(
              padding: EdgeInsets.only(left: withPadding ? 8 : 0, right: withPadding ? 0 : 12),
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (enabled && _hasInput)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              color: Colors.grey,
              onPressed: _clearSearch,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            SizedBox(width: withPadding ? 0 : 12),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestion() {
    final keyword = _controller.text.trim();
    return _buildSearchItem(
      text: keyword,
      onTap: () {
        _handleItemTap(SearchResultItem(
          id: keyword,
          title: keyword,
        ));
      },
    );
  }

  Widget _buildEnglishSearchList() {
    final keyword = _controller.text.trim();

    // 正在搜索或无结果：只显示"搜索 XXX"
    if (_isSearching || _results.isEmpty) {
      return _buildSearchAllItem(keyword);
    }

    // 有结果：显示最多5个结果 + "搜索 XXX"
    final displayResults = _results.take(5).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: displayResults.length + 1,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey[200],
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (_, index) {
          return index < displayResults.length
              ? _buildResultItem(displayResults[index])
              : _buildSearchAllItem(keyword);
        },
      ),
    );
  }

  Widget _buildSearchAllItem(String keyword) {
    return _buildSearchItem(
      text: '搜索 $keyword',
      onTap: () {
        _navigateToSearchResult(keyword);
      },
    );
  }

  Widget _buildSearchItem({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.search, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(SearchResultItem item) {
    return InkWell(
      onTap: () {
        _handleItemTap(item);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 20, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// 带返回按钮的搜索栏（用于全屏搜索页面）
class SearchBarWithCancel extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final VoidCallback? onCancel;
  final ValueChanged<String>? onChanged;
  final EdgeInsets? padding;

  const SearchBarWithCancel({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.onCancel,
    this.onChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: onCancel,
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
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintText ?? '搜索',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
