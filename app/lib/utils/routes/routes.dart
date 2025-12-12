import 'package:fastapp/presentation/views/home/home_screen.dart';
import 'package:fastapp/presentation/views/home/service_screen.dart';
import 'package:fastapp/presentation/views/market/market_screen.dart';
import 'package:fastapp/presentation/views/c2c/c2c_screen.dart';
import 'package:fastapp/presentation/views/user/login.dart';
import 'package:fastapp/presentation/views/user/forgot_password.dart';
import 'package:fastapp/presentation/views/user/register.dart';
import 'package:fastapp/presentation/views/user/user_center.dart';
import 'package:fastapp/presentation/views/user/setting/account_security.dart';
import 'package:fastapp/presentation/views/user/setting/account_activity.dart';
import 'package:fastapp/presentation/views/user/setting/authenticator_app.dart';
import 'package:fastapp/presentation/views/user/setting/identity_verification.dart';
import 'package:fastapp/presentation/views/user/setting/vip_privilege.dart';
import 'package:fastapp/presentation/views/user/setting/manage_account.dart';
import 'package:fastapp/presentation/views/user/setting/phone_verification.dart';
import 'package:fastapp/presentation/views/user/setting/settings_screen.dart';
import 'package:fastapp/presentation/views/user/setting/account_binding.dart';
import 'package:fastapp/presentation/views/user/setting/email_binding.dart';
import 'package:fastapp/presentation/views/user/setting/mobile_binding.dart';
import 'package:fastapp/presentation/views/user/setting/password_setting.dart';
import 'package:fastapp/presentation/views/user/message/message_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  static const String home = '/home';
  static const String market = '/market';
  static const String c2c = '/c2c';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String userCenter = '/user-center';
  static const String profile = '/profile';
  static const String accountSecurity = '/account-security';
  static const String accountActivity = '/account-activity';
  static const String authenticatorApp = '/authenticator-app';
  static const String identityVerification = '/identity-verification';
  static const String vipPrivilege = '/vip-privilege';
  static const String manageAccount = '/manage-account';
  static const String phoneVerification = '/phone-verification';
  static const String accountBinding = '/account-binding';
  static const String emailBinding = '/email-binding';
  static const String mobileBinding = '/mobile-binding';
  static const String passwordSetting = '/password-setting';
  static const String settings = '/settings';
  static const String message = '/message';
  static const String service = '/service';

  static final routes = <String, WidgetBuilder>{
    home: (BuildContext context) => const HomeScreen(),
    market: (BuildContext context) => const MarketScreen(),
    c2c: (BuildContext context) => const C2CScreen(),
    login: (BuildContext context) => LoginScreen(),
    register: (BuildContext context) => RegisterScreen(),
    forgotPassword: (BuildContext context) => ForgotPasswordScreen(),
    userCenter: (BuildContext context) => const UserCenterScreen(),
    profile: (BuildContext context) => const UserCenterScreen(),
    accountSecurity: (BuildContext context) => const AccountSecurityScreen(),
    accountActivity: (BuildContext context) => const AccountActivityScreen(),
    authenticatorApp: (BuildContext context) => const AuthenticatorAppScreen(),
    identityVerification: (BuildContext context) => const IdentityVerificationScreen(),
    vipPrivilege: (BuildContext context) => const VipPrivilegeScreen(),
    manageAccount: (BuildContext context) => const ManageAccountScreen(),
    phoneVerification: (BuildContext context) => const PhoneVerificationScreen(),
    accountBinding: (BuildContext context) => const AccountBindingScreen(),
    emailBinding: (BuildContext context) => const EmailBindingScreen(),
    mobileBinding: (BuildContext context) => const MobileBindingScreen(),
    passwordSetting: (BuildContext context) => const PasswordSettingScreen(),
    settings: (BuildContext context) => const SettingsScreen(),
    message: (BuildContext context) => const MessageScreen(),
    service: (BuildContext context) => const ServiceScreen(),
  };
}
