import 'package:fastapp/constants/theme_config.dart';

/// 暗色主题配置
const darkTheme = ThemeConfig(
  id: 'dark',
  name: '暗色',

  // 主色调 - 蓝色
  seedColor: '#2196F3',

  // 页面背景 - 使用系统默认
  scaffoldBackground: null,

  button: ButtonColors(
    background: '#757575',           // 中灰色按钮背景
    foreground: '#FFFFFF',           // 白色文字
    disabledBackground: '#616161',   // 禁用状态深灰背景
    disabledForeground: '#B3FFFFFF', // 禁用状态半透明白色
  ),

  text: TextColors(
    primary: '#FFFFFF',     // 主文字 - 纯白
    secondary: '#B0B0B0',   // 次要文字 - 浅灰
    hint: '#757575',        // 提示文字 - 中灰
    disabled: '#616161',    // 禁用文字 - 深灰
  ),

  border: BorderColors(
    defaultColor: '#424242',  // 默认边框 - 深灰
    focused: '#2196F3',       // 聚焦边框 - 主色调蓝色
    error: '#F44336',         // 错误边框 - 红色
  ),

  status: StatusColors(
    success: '#4CAF50',  // 成功状态 - 绿色
    error: '#F44336',    // 错误状态 - 红色
    warning: '#FF9800',  // 警告状态 - 橙色
    info: '#2196F3',     // 信息状态 - 蓝色
  ),

  background: BackgroundColors(
    scaffold: null,               // 页面背景 - 使用系统默认
    page: '#121212',              // 内容区背景 - 极深灰
    card: '#1E1E1E',              // 卡片背景 - 深灰
    section: '#2C2C2C',           // 区域背景 - 中深灰
    input: '#2C2C2C',             // 输入框背景 - 中深灰
    dialog: '#1E1E1E',            // 对话框背景 - 深灰
    bottomSheet: '#1E1E1E',       // 底部抽屉背景 - 深灰
    elevated: '#2C2C2C',          // 悬浮元素背景 - 中深灰
  ),
);
