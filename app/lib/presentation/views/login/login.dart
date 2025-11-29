import 'package:another_flushbar/flushbar_helper.dart';
import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/core/stores/form/form_store.dart';
import 'package:fastapp/core/widgets/empty_app_bar_widget.dart';
import 'package:fastapp/core/widgets/progress_indicator_widget.dart';
import 'package:fastapp/data/sharedpref/constants/preferences.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/utils/device/device_utils.dart';
import 'package:fastapp/utils/locale/app_localization.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastapp/di/service_locator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _phoneController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //country code:---------------------------------------------------------------
  String _selectedCountryCode = '+86';
  String _selectedCountryFlag = '🇨🇳';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 40.0),
                // 标题
                Text(
                  '登录',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 32.0),
                // 邮箱/手机号码标签
                Text(
                  '邮箱/手机号码',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.0),
                // 手机号输入框
                _buildPhoneField(),
                SizedBox(height: 24.0),
                // 继续按钮
                _buildContinueButton(),
                SizedBox(height: 32.0),
                // 分隔线
                _buildDivider(),
                SizedBox(height: 32.0),
                // 其他登录方式
                _buildAlternativeLoginOptions(),
                SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
        Observer(
          builder: (context) {
            return _userStore.success
                ? navigate(context)
                : _showErrorMessage(_formStore.errorStore.errorMessage);
          },
        ),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _userStore.isLoading,
              child: CustomProgressIndicatorWidget(),
            );
          },
        ),
        // 底部链接
        Positioned(
          bottom: 20.0,
          left: 24.0,
          child: TextButton(
            onPressed: () {
              // TODO: 导航到注册页面
            },
            child: Text(
              '创建币安账户',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          // 国家代码选择器
          InkWell(
            onTap: () => _showCountryCodePicker(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCountryFlag,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    _selectedCountryCode,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20.0,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          // 分隔线
          Container(
            width: 1.0,
            height: 24.0,
            color: Colors.grey[300],
          ),
          // 电话号码输入
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '请输入手机号码',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                suffixIcon: _phoneController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 20.0),
                        onPressed: () {
                          setState(() {
                            _phoneController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 48.0,
      child: ElevatedButton(
        onPressed: () async {
          if (_phoneController.text.isNotEmpty) {
            DeviceUtils.hideKeyboard(context);
            // TODO: 处理登录逻辑
            final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
            // 临时使用邮箱登录逻辑
            _userStore.login(phoneNumber, 'password');
          } else {
            _showErrorMessage('请输入手机号码');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          '继续',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '或',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.0,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeLoginOptions() {
    return Column(
      children: [
        // 使用手机号登录（带头像图标）
        _buildAlternativeLoginButton(
          icon: Icons.person,
          text: '使用手机号登录',
          onPressed: () {
            // TODO: 处理手机号登录
          },
        ),
        SizedBox(height: 12.0),
        // Google登录
        _buildGoogleLoginButton(),
      ],
    );
  }

  Widget _buildAlternativeLoginButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48.0,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87),
            SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      height: 48.0,
      child: OutlinedButton(
        onPressed: () {
          // TODO: 处理Google登录
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G logo (使用文字模拟)
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Text(
              '通过 Google 继续',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300.0,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '选择国家/地区',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildCountryCodeItem('🇨🇳', '+86', '中国'),
                    _buildCountryCodeItem('🇺🇸', '+1', '美国'),
                    _buildCountryCodeItem('🇬🇧', '+44', '英国'),
                    _buildCountryCodeItem('🇯🇵', '+81', '日本'),
                    _buildCountryCodeItem('🇰🇷', '+82', '韩国'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountryCodeItem(String flag, String code, String name) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24.0)),
      title: Text(name),
      trailing: Text(code),
      onTap: () {
        setState(() {
          _selectedCountryFlag = flag;
          _selectedCountryCode = code;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(Duration(milliseconds: 0), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
