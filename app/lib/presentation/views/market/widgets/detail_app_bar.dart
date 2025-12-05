import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/market/widgets/symbol_selector_bottom_sheet.dart';

/// 交易详情页面顶部导航栏
class DetailAppBar extends StatelessWidget {
  final String symbolName;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final ValueChanged<String>? onSymbolChanged;

  const DetailAppBar({
    super.key,
    required this.symbolName,
    required this.isFavorite,
    required this.onBack,
    required this.onFavoriteToggle,
    required this.onShare,
    required this.onMore,
    this.onSymbolChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: onBack,
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                SymbolSelectorBottomSheet.show(
                  context,
                  currentSymbol: symbolName,
                  onSymbolSelected: (symbol) {
                    onSymbolChanged?.call(symbol);
                  },
                );
              },
              child: Row(
                children: [
                  Text(
                    symbolName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('永续', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : Colors.black87,
            ),
            onPressed: onFavoriteToggle,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: onShare,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}
