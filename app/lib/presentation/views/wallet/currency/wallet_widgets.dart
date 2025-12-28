import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 钱包页面公共UI组件
class WalletWidgets {
  /// 构建标准的输入字段容器
  static Widget buildFieldContainer(
    BuildContext context, {
    VoidCallback? onTap,
    required Widget child,
  }) {
    final backgroundTheme = context.backgroundTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundTheme.input,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }

  /// 构建信息行（标签-值）
  static Widget buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = context.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: textTheme.secondary)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: textTheme.primary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// 构建警告横幅
  static Widget buildWarningBanner(BuildContext context, String message) {
    final statusTheme = context.statusTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: statusTheme.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: statusTheme.warning),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主按钮
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 构建复制按钮
  static Widget buildCopyButton({
    required BuildContext context,
    required String text,
    required String label,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label已复制'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.copy, size: 16),
        label: Text('复制$label'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  /// 构建标准的TextField
  static Widget buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    void Function(String)? onChanged,
    Widget? suffix,
  }) {
    final textTheme = context.textTheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textTheme.hint, fontSize: 14),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        counterText: maxLength != null ? '' : null,
        suffix: suffix,
      ),
      style: TextStyle(fontSize: 14, color: textTheme.primary),
      onChanged: onChanged,
    );
  }

  /// 构建币种图标
  static Widget buildCoinIcon(
    BuildContext context, {
    required String symbol,
    String? logoUrl,
    double size = 40,
  }) {
    final backgroundTheme = context.backgroundTheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundTheme.input,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl != null
          ? Image.network(
              logoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildIconText(symbol, size),
            )
          : _buildIconText(symbol, size),
    );
  }

  static Widget _buildIconText(String symbol, double size) {
    return Center(
      child: Text(
        symbol.isNotEmpty ? symbol[0] : 'C',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建选择器行（带右箭头）
  static Widget buildSelectorRow(
    BuildContext context, {
    required String label,
    required String? selectedValue,
    required VoidCallback onTap,
  }) {
    final textTheme = context.textTheme;

    return buildFieldContainer(
      context,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedValue ?? '请选择$label',
            style: TextStyle(
              fontSize: 14,
              color: selectedValue != null ? textTheme.primary : textTheme.hint,
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: textTheme.hint),
        ],
      ),
    );
  }

  /// 构建底部弹窗选择器
  static Future<T?> showBottomPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemBuilder,
    String Function(T)? subtitleBuilder,
    T? selectedItem,
  }) {
    final textTheme = context.textTheme;

    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textTheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(itemBuilder(item)),
                    subtitle: subtitleBuilder != null ? Text(subtitleBuilder(item)) : null,
                    selected: selectedItem == item,
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
