import 'package:fastapp/presentation/views/home/home_screen.dart';
import 'package:fastapp/presentation/views/market/market_screen.dart';
import 'package:fastapp/presentation/views/market/depth_screen.dart';
import 'package:fastapp/presentation/views/user/login.dart';
import 'package:fastapp/presentation/views/user/forgot_password.dart';
import 'package:fastapp/presentation/views/user/register.dart';
import 'package:fastapp/presentation/views/user/user_center.dart';
import 'package:fastapp/presentation/views/user/profile.dart';
import 'package:fastapp/presentation/views/user/setting/settings_screen.dart';
import 'package:fastapp/presentation/views/user/message/message_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  static const String home = '/home';
  static const String market = '/market';
  static const String depth = '/depth';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String userCenter = '/user-center';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String message = '/message';

  static final routes = <String, WidgetBuilder>{
    home: (BuildContext context) => const HomeScreen(),
    market: (BuildContext context) => const MarketScreen(),
    depth: (BuildContext context) => const DepthScreen(),
    login: (BuildContext context) => LoginScreen(),
    register: (BuildContext context) => RegisterScreen(),
    forgotPassword: (BuildContext context) => ForgotPasswordScreen(),
    userCenter: (BuildContext context) => const UserCenterScreen(),
    profile: (BuildContext context) => const ProfileScreen(),
    settings: (BuildContext context) => const SettingsScreen(),
    message: (BuildContext context) => const MessageScreen(),
  };
}
