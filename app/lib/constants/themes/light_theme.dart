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

  feed: FeedColors(
    cardBackground: '#FFFFFF',      // 信息流卡片背景 - 纯白
    userNameText: '#212121',        // 用户名 - 深黑
    timeText: '#757575',            // 时间文字 - 中灰
    contentText: '#424242',         // 内容文字 - 深灰
    titleText: '#212121',           // 标题文字 - 深黑
    linkText: '#FF9500',            // 链接文字 - 主题橙色
    menuIcon: '#9E9E9E',            // 菜单图标 - 浅灰
    actionIconActive: '#FF9500',    // 操作按钮激活状态 - 主题橙色
    actionIconDefault: '#757575',   // 操作按钮默认状态 - 中灰
    actionTextActive: '#FF9500',    // 操作文字激活状态 - 主题橙色
    actionTextDefault: '#757575',   // 操作文字默认状态 - 中灰
  ),

  emptyState: EmptyStateColors(
    icon: '#BDBDBD',                // 空状态图标 - 浅灰
    titleText: '#616161',           // 空状态标题 - 中深灰
    descriptionText: '#9E9E9E',     // 空状态描述 - 浅灰
    buttonBackground: '#FF9500',    // 按钮背景 - 主题橙色
    buttonForeground: '#FFFFFF',    // 按钮文字 - 纯白
  ),

  bottomNav: BottomNavColors(
    background: '#FFFFFF',          // 底部导航背景 - 纯白
    selectedItem: '#FF9500',        // 选中项 - 主题橙色
    unselectedItem: '#9E9E9E',      // 未选中项 - 浅灰
  ),
);
