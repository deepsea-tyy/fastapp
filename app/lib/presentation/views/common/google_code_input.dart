import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 6格数字输入组件（用于Google验证码输入）
class CodeInputField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const CodeInputField({
    super.key,
    required this.label,
    this.initialValue,
    this.autofocus = false,
    this.onChanged,
    this.validator,
  });

  @override
  State<CodeInputField> createState() => CodeInputFieldState();
}

class CodeInputFieldState extends State<CodeInputField> {
  static const int _codeLength = 6;
  final List<TextEditingController> _controllers = List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  final GlobalKey<FormFieldState<String>> _formKey = GlobalKey<FormFieldState<String>>();
  String _code = '';

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    if (initialValue != null && initialValue.length == _codeLength) {
      for (int i = 0; i < _codeLength; i++) {
        _controllers[i].text = initialValue[i];
      }
      _code = initialValue;
    }
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var focusNode in _focusNodes) focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    final code = _controllers.map((c) => c.text).join();
    if (_code != code) {
      _code = code;
      widget.onChanged?.call(code);
      // 触发 FormField 状态更新
      if (mounted) {
        final previousHasError = _formKey.currentState?.hasError ?? false;
        _formKey.currentState?.didChange(code);
        // 只在验证状态改变时才调用setState，避免不必要的重建
        // 这样可以防止TextField内容闪烁
        final currentHasError = _formKey.currentState?.hasError ?? false;
        if (previousHasError != currentHasError) {
          setState(() {});
        }
      }
    }
  }

  void _onTextChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(index, value);
    } else {
      // 由于 maxLength: 1，value 应该已经是单个字符或空字符串
      // 不需要再次设置 controller.text，因为 TextField 已经自动更新了
      // 只需要更新内部状态和焦点
      if (value.isNotEmpty && index < _codeLength - 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNodes[index + 1].requestFocus();
        });
      }
    }
    _onChanged();
  }

  void _handlePaste(int index, String value) {
    final pastedCode = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (pastedCode.length >= _codeLength) {
      for (int i = 0; i < _codeLength; i++) {
        _controllers[i].text = pastedCode[i];
        _controllers[i].selection = TextSelection.collapsed(offset: 1);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[_codeLength - 1].requestFocus();
      });
    } else {
      _controllers[index].text = pastedCode.isNotEmpty ? pastedCode[0] : '';
      _controllers[index].selection = TextSelection.collapsed(offset: _controllers[index].text.length);
      if (pastedCode.length > 1) {
        for (int i = 1; i < pastedCode.length && (index + i) < _codeLength; i++) {
          _controllers[index + i].text = pastedCode[i];
          _controllers[index + i].selection = TextSelection.collapsed(offset: 1);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNodes[(index + pastedCode.length).clamp(0, _codeLength - 1)].requestFocus();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formKey,
      initialValue: _code,
      validator: widget.validator,
      builder: (field) {
        final hasError = field.hasError;
        final primaryColor = Theme.of(context).colorScheme.primary;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_codeLength, (index) => _buildCodeInput(
                context,
                index,
                field: field,
                hasError: hasError,
                primaryColor: primaryColor,
              )),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCodeInput(
    BuildContext context,
    int index, {
    required FormFieldState<String> field,
    required bool hasError,
    required Color primaryColor,
  }) {
    final borderColor = hasError
        ? Colors.red
        : (_focusNodes[index].hasFocus ? primaryColor : Colors.transparent);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor, width: 2),
    );

    return SizedBox(
      width: 45,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.0,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: border.copyWith(borderSide: BorderSide.none),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.red, width: 2)),
          focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.red, width: 2)),
        ),
        onChanged: (value) => _onTextChanged(index, value),
        onSubmitted: (_) {
          if (index < _codeLength - 1) _focusNodes[index + 1].requestFocus();
        },
        onTap: () {
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
      ),
    );
  }

  String get value => _code;

  /// 清空所有输入框
  void clear() {
    for (int i = 0; i < _codeLength; i++) {
      _controllers[i].clear();
    }
    _code = '';
    if (mounted) {
      setState(() {});
      _formKey.currentState?.didChange('');
    }
  }
}
