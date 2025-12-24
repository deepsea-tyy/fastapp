/// 主题配置类
class ThemeConfig {
  final String id;
  final String name;
  final String seedColor;
  final String? scaffoldBackground;
  final ButtonColors button;
  final TextColors text;
  final BorderColors border;
  final StatusColors status;
  final BackgroundColors background;

  const ThemeConfig({
    required this.id,
    required this.name,
    required this.seedColor,
    this.scaffoldBackground,
    required this.button,
    required this.text,
    required this.border,
    required this.status,
    required this.background,
  });
}

/// 按钮颜色配置
class ButtonColors {
  final String background;
  final String foreground;
  final String disabledBackground;
  final String disabledForeground;

  const ButtonColors({
    required this.background,
    required this.foreground,
    required this.disabledBackground,
    required this.disabledForeground,
  });
}

/// 文字颜色配置
class TextColors {
  final String primary;
  final String secondary;
  final String hint;
  final String disabled;

  const TextColors({
    required this.primary,
    required this.secondary,
    required this.hint,
    required this.disabled,
  });
}

/// 边框颜色配置
class BorderColors {
  final String defaultColor;
  final String focused;
  final String error;

  const BorderColors({
    required this.defaultColor,
    required this.focused,
    required this.error,
  });
}

/// 状态颜色配置
class StatusColors {
  final String success;
  final String error;
  final String warning;
  final String info;

  const StatusColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });
}

/// 背景颜色配置
class BackgroundColors {
  final String? scaffold;
  final String? page;
  final String card;
  final String? section;
  final String input;
  final String? dialog;
  final String? bottomSheet;
  final String? elevated;

  const BackgroundColors({
    this.scaffold,
    this.page,
    required this.card,
    this.section,
    required this.input,
    this.dialog,
    this.bottomSheet,
    this.elevated,
  });
}
