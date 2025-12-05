import 'package:fastapp/presentation/views/spot/widgets/spot/form/utils.dart';
import 'package:flutter/material.dart';

/// 通用选择底部弹窗（用于单选场景）
class SelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<SelectionOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final bool showButton;
  final String? buttonText;
  final Widget? footer;
  final bool useListTileStyle;

  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.selectedValue,
    required this.onSelected,
    this.showButton = false,
    this.buttonText,
    this.footer,
    this.useListTileStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragHandle(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: useListTileStyle ? 0 : 0,
              vertical: useListTileStyle ? 8 : 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: useListTileStyle ? 14 : 18,
                  fontWeight: FontWeight.bold,
                  color: useListTileStyle ? Colors.grey.shade600 : Colors.black87,
                ),
              ),
            ),
          ),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedValue != null && selectedValue == option.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < options.length - 1 ? (useListTileStyle ? 0 : 12) : (showButton || footer != null ? 16 : (useListTileStyle ? 4 : 0))),
              child: useListTileStyle
                  ? _buildListTileOption(option, isSelected: isSelected, onTap: () {
                      onSelected(option.value);
                      if (!showButton) {
                        Navigator.of(context).pop();
                      }
                    })
                  : _buildOption(
                      option,
                      isSelected: isSelected,
                      onTap: () {
                        onSelected(option.value);
                        if (!showButton) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
            );
          }),
          if (footer != null) ...[
            const SizedBox(height: 8),
            footer!,
          ],
          if (showButton) ...[
            const SizedBox(height: 24),
            buildBottomSheetButton(
              onPressed: () => Navigator.of(context).pop(),
              text: buttonText ?? '确定',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(SelectionOption<T> option, {required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: option.description != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              )
            : Text(
                option.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
      ),
    );
  }

  Widget _buildListTileOption(SelectionOption<T> option, {required bool isSelected, required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        option.title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.black87, size: 20) : null,
      onTap: onTap,
    );
  }
}

/// 选择项数据模型
class SelectionOption<T> {
  final String title;
  final String? description;
  final T value;

  const SelectionOption({
    required this.title,
    this.description,
    required this.value,
  });
}
