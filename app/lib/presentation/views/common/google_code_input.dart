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
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus(0));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var focusNode in _focusNodes) focusNode.dispose();
    super.dispose();
  }

  /// 取消所有其他输入框的焦点
  void _unfocusOthers(int excludeIndex) {
    for (int i = 0; i < _codeLength; i++) {
      if (i != excludeIndex && _focusNodes[i].hasFocus) {
        _focusNodes[i].unfocus();
      }
    }
  }

  /// 请求焦点并选中文本（如果有值）
  void _requestFocus(int index, {bool selectText = false}) {
    Future.microtask(() {
      if (!mounted) return;
      _unfocusOthers(index);
      _focusNodes[index].requestFocus();
      if (selectText && _controllers[index].text.isNotEmpty) {
        _controllers[index].selection = TextSelection(baseOffset: 0, extentOffset: 1);
      }
    });
  }

  void _onChanged() {
    final code = _controllers.map((c) => c.text).join();
    if (_code == code) return;
    
    _code = code;
    widget.onChanged?.call(code);
    
    if (!mounted) return;
    final hadError = _formKey.currentState?.hasError ?? false;
    _formKey.currentState?.didChange(code);
    if (hadError != (_formKey.currentState?.hasError ?? false)) {
      setState(() {});
    }
  }

  void _onTextChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(index, value);
      return;
    }
    
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index].unfocus();
      _requestFocus(index + 1, selectText: true);
    }
    
    _onChanged();
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
    } else if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index].unfocus();
      _requestFocus(index - 1);
    }
    _onChanged();
  }

  void _handlePaste(int index, String value) {
    final pastedCode = value.replaceAll(RegExp(r'[^0-9]'), '');
    final endIndex = (index + pastedCode.length).clamp(0, _codeLength);
    final count = endIndex - index;
    
    for (var focusNode in _focusNodes) {
      if (focusNode.hasFocus) focusNode.unfocus();
    }
    
    for (int i = 0; i < count; i++) {
      _controllers[index + i].text = pastedCode[i];
    }
    
    final targetIndex = endIndex < _codeLength ? endIndex : _codeLength - 1;
    _requestFocus(targetIndex);
    _onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formKey,
      initialValue: _code,
      validator: widget.validator,
      builder: (field) {
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
              children: List.generate(_codeLength, (index) => Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == _codeLength - 1 ? 0 : 4,
                  ),
                  child: _buildCodeInput(index, field.hasError, primaryColor),
                ),
              )),
            ),
            if (field.hasError)
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

  Widget _buildCodeInput(int index, bool hasError, Color primaryColor) {
    final isFocused = _focusNodes[index].hasFocus;
    final borderColor = hasError
        ? Colors.red
        : (isFocused ? primaryColor : Colors.grey.shade400);
    
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor, width: 2),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 40, maxWidth: 50),
      child: SizedBox(
        height: 56,
        child: KeyboardListener(
          focusNode: FocusNode(skipTraversal: true),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              _handleBackspace(index);
            }
          },
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            showCursor: false,
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
              focusedBorder: border.copyWith(borderSide: BorderSide(color: primaryColor, width: 2)),
              errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.red, width: 2)),
              focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.red, width: 2)),
            ),
            onChanged: (value) => _onTextChanged(index, value),
            onTap: () => _requestFocus(index, selectText: true),
          ),
        ),
      ),
    );
  }

  String get value => _code;

  void clear() {
    for (var controller in _controllers) controller.clear();
    _code = '';
    if (mounted) {
      setState(() {});
      _formKey.currentState?.didChange('');
    }
  }
}
