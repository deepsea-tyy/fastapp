import 'package:flutter/material.dart';

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
  // 常量定义
  static const double _overlayMargin = 16.0;
  static const double _overlayGap = 8.0;
  static const double _maxResultHeight = 300.0;
  static const int _overlayCloseDelay = 200;

  // 控制器和状态
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final GlobalKey _searchBarKey = GlobalKey();

  List<SearchResultItem> _results = [];
  bool _isSearching = false;
  bool _showResults = false;
  OverlayEntry? _overlayEntry;

  bool get _isNavigationMode => widget.onTap != null;
  bool get _hasInput => _controller.text.trim().isNotEmpty;
  bool get _shouldShowOverlay => _hasInput && (_showResults || !_isSearching);

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
    setState(() {});
    _shouldShowOverlay ? _updateOverlay() : _removeOverlay();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: _overlayCloseDelay), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
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
    return Stack(
      children: [
        _buildOverlayMask(offset, size, screenSize),
        _buildOverlayContent(offset, size, screenSize.width),
      ],
    );
  }

  Widget _buildOverlayMask(Offset offset, Size size, Size screenSize) {
    return Positioned(
      top: offset.dy + size.height,
      width: screenSize.width,
      height: screenSize.height - (offset.dy + size.height),
      child: GestureDetector(
        onTap: () {
          _removeOverlay();
          _focusNode.unfocus();
        },
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildOverlayContent(Offset offset, Size size, double screenWidth) {
    return Positioned(
      left: _overlayMargin,
      top: offset.dy + size.height + _overlayGap,
      width: screenWidth - _overlayMargin * 2,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: _showResults ? _buildResultsList() : _buildSearchSuggestion(),
      ),
    );
  }

  Future<void> _performSearch(String keyword) async {
    if (widget.onSearch == null) return;

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      final results = await widget.onSearch!(keyword);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
        _updateOverlay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
        _updateOverlay();
      }
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _results = [];
      _showResults = false;
    });
    _removeOverlay();
  }

  void _handleItemTap(SearchResultItem item) {
    widget.onItemTap?.call(item);
    setState(() => _showResults = false);
    _removeOverlay();
    _focusNode.unfocus();
  }

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
    return Container(
      key: _searchBarKey,
      height: widget.height ?? 40,
      margin: widget.showBackButton ? null : (widget.margin ?? const EdgeInsets.fromLTRB(16, 16, 16, 0)),
      padding: withPadding ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10) : null,
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
          Expanded(child: _buildTextField(enabled, withPadding)),
          _buildTrailingWidget(enabled, withPadding),
        ],
      ),
    );
  }

  Widget _buildTextField(bool enabled, bool withPadding) {
    return TextField(
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
        filled: false,
        isDense: true,
        contentPadding: withPadding ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      onSubmitted: enabled ? (value) {
        final keyword = value.trim();
        if (keyword.isNotEmpty) _performSearch(keyword);
      } : null,
    );
  }

  Widget _buildTrailingWidget(bool enabled, bool withPadding) {
    if (!enabled) {
      return const SizedBox(width: 12);
    }

    if (_isSearching) {
      return Padding(
        padding: EdgeInsets.only(left: withPadding ? 8 : 0, right: withPadding ? 0 : 12),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_hasInput) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 18),
        color: Colors.grey,
        onPressed: _clearSearch,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return SizedBox(width: withPadding ? 0 : 12);
  }

  Widget _buildSearchSuggestion() {
    return InkWell(
      onTap: () => _performSearch(_controller.text.trim()),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.search, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _controller.text.trim(),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_results.isEmpty && !_isSearching) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '无搜索结果',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: _maxResultHeight),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _results.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey[200],
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (_, index) => _buildResultItem(_results[index]),
      ),
    );
  }

  Widget _buildResultItem(SearchResultItem item) {
    return InkWell(
      onTap: () => _handleItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (item.imageUrl != null) ...[
              _buildResultImage(item.imageUrl!),
              const SizedBox(width: 12),
            ],
            Expanded(child: _buildResultText(item)),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildResultImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
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
    );
  }

  Widget _buildResultText(SearchResultItem item) {
    return Column(
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
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
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
