import 'package:fastapp/constants/theme_config.dart';

/// 亮色主题配置
const lightTheme = ThemeConfig(
  id: 'light',
  name: '亮色',

  // 主色调 - 橙色
  seedColor: '#FF9500',

  // 页面背景 - 纯白
  scaffoldBackground: '#FFFFFF',

  button: ButtonColors(
    background: '#424242',           // 深灰色按钮背景
    foreground: '#FFFFFF',           // 白色文字
    disabledBackground: '#BDBDBD',   // 禁用状态浅灰背景
    disabledForeground: '#B3FFFFFF', // 禁用状态半透明白色
  ),

  text: TextColors(
    primary: '#212121',     // 主文字 - 深黑
    secondary: '#757575',   // 次要文字 - 中灰
    hint: '#9E9E9E',        // 提示文字 - 浅灰
    disabled: '#BDBDBD',    // 禁用文字 - 更浅灰
  ),

  border: BorderColors(
    defaultColor: '#E0E0E0',  // 默认边框 - 浅灰
    focused: '#FF9500',       // 聚焦边框 - 主色调橙色
    error: '#F44336',         // 错误边框 - 红色
  ),

  status: StatusColors(
    success: '#4CAF50',  // 成功状态 - 绿色
    error: '#F44336',    // 错误状态 - 红色
    warning: '#FF9800',  // 警告状态 - 橙色
    info: '#2196F3',     // 信息状态 - 蓝色
  ),

  background: BackgroundColors(
    scaffold: '#FFFFFF',     // 页面背景 - 纯白
    page: '#F5F5F5',         // 内容区背景 - 浅灰
    card: '#FFFFFF',         // 卡片背景 - 纯白
    section: '#FAFAFA',      // 区域背景 - 极浅灰
    input: '#F5F5F5',        // 输入框背景 - 浅灰
    dialog: '#FFFFFF',       // 对话框背景 - 纯白
    bottomSheet: '#FFFFFF',  // 底部抽屉背景 - 纯白
    elevated: '#FFFFFF',     // 悬浮元素背景 - 纯白
  ),
);
