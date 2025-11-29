import 'package:fastapp/presentation/views/home/home_screen.dart';
import 'package:fastapp/presentation/views/market/market_screen.dart';
import 'package:fastapp/presentation/views/market/depth_screen.dart';
import 'package:fastapp/presentation/views/login/login.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  static const String home = '/home';
  static const String market = '/market';
  static const String depth = '/depth';
  static const String login = '/login';

  static final routes = <String, WidgetBuilder>{
    home: (BuildContext context) => const HomeScreen(),
    market: (BuildContext context) => const MarketScreen(),
    depth: (BuildContext context) => const DepthScreen(),
    login: (BuildContext context) => LoginScreen(),
  };
}
