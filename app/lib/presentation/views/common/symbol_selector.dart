import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 交易对选择器组件
class SymbolSelector extends StatelessWidget {
  final List<String> symbols;
  final String selectedSymbol;
  final ValueChanged<String> onSymbolSelected;

  const SymbolSelector({
    super.key,
    required this.symbols,
    required this.selectedSymbol,
    required this.onSymbolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: symbols.length,
        itemBuilder: (context, index) {
          final symbol = symbols[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(symbol),
              selected: selectedSymbol == symbol,
              onSelected: (selected) {
                if (selected) {
                  onSymbolSelected(symbol);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/// 带 Observer 的交易对选择器
class ObservableSymbolSelector extends StatelessWidget {
  final List<String> symbols;
  final String Function() selectedSymbolGetter;
  final ValueChanged<String> onSymbolSelected;

  const ObservableSymbolSelector({
    super.key,
    required this.symbols,
    required this.selectedSymbolGetter,
    required this.onSymbolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SymbolSelector(
        symbols: symbols,
        selectedSymbol: selectedSymbolGetter(),
        onSymbolSelected: onSymbolSelected,
      ),
    );
  }
}

