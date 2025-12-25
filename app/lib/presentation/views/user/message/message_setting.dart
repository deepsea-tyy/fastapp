import 'package:flutter/material.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/presentation/views/common/modern_switch.dart';
import 'package:fastapp/presentation/views/common/modern_settings_tile.dart';

/// 通知偏好设置页面
class MessageSettingScreen extends StatefulWidget {
  const MessageSettingScreen({super.key});

  @override
  State<MessageSettingScreen> createState() => _MessageSettingScreenState();
}

class _MessageSettingScreenState extends State<MessageSettingScreen> {
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();

  bool _marketingActivities = false;
  bool _transactions = false;
  bool _priceAlerts = false;
  bool _account = false;
  bool _feedbackSuggestions = false;
  bool _orderTrade = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 从用户信息加载设置
  void _loadSettings() {
    final setting = _userStore.currentUser?.profile?.setting;
    if (setting != null) {
      setState(() {
        _marketingActivities = setting['zex_msg_marketing'] == 1;
        _transactions = setting['zex_msg_trade'] == 1;
        _priceAlerts = setting['zex_msg_price'] == 1;
        _account = setting['zex_msg_account'] == 1;
        _feedbackSuggestions = setting['zex_msg_feedback'] == 1;
        _orderTrade = setting['zex_msg_order_trade'] == 1;
      });
    }
  }

  /// 更新设置到服务器
  Future<void> _updateSetting(Map<String, dynamic> updates) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _userApi.updateProfile(setting: updates);
    } catch (e) {
      _loadSettings();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '消息设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          const ModernSectionHeader(
            title: '消息通知',
            subtitle: '管理各类消息推送设置',
          ),
          ModernSettingsGroup(
            children: [
              ModernSwitchTile(
                icon: Icons.campaign_outlined,
                title: '营销与活动',
                subtitle: '接收平台的营销活动和推广信息',
                value: _marketingActivities,
                onChanged: (value) {
                  setState(() => _marketingActivities = value);
                  _updateSetting({'zex_msg_marketing': value ? 1 : 0});
                },
              ),
              ModernSwitchTile(
                icon: Icons.swap_horiz,
                title: '交易',
                subtitle: '接收交易相关的通知',
                value: _transactions,
                onChanged: (value) {
                  setState(() => _transactions = value);
                  _updateSetting({'zex_msg_trade': value ? 1 : 0});
                },
              ),
              ModernSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: '价格提醒',
                subtitle: '接收价格变动提醒',
                value: _priceAlerts,
                onChanged: (value) {
                  setState(() => _priceAlerts = value);
                  _updateSetting({'zex_msg_price': value ? 1 : 0});
                },
              ),
              ModernSwitchTile(
                icon: Icons.account_circle_outlined,
                title: '账户',
                subtitle: '接收账户安全和状态变更通知',
                value: _account,
                onChanged: (value) {
                  setState(() => _account = value);
                  _updateSetting({'zex_msg_account': value ? 1 : 0});
                },
              ),
              ModernSwitchTile(
                icon: Icons.feedback_outlined,
                title: '反馈与产品建议',
                subtitle: '接收反馈回复和产品更新通知',
                value: _feedbackSuggestions,
                onChanged: (value) {
                  setState(() => _feedbackSuggestions = value);
                  _updateSetting({'zex_msg_feedback': value ? 1 : 0});
                },
              ),
              ModernSwitchTile(
                icon: Icons.receipt_long_outlined,
                title: '订单交易推送',
                subtitle: '接收订单状态和交易完成通知',
                value: _orderTrade,
                onChanged: (value) {
                  setState(() => _orderTrade = value);
                  _updateSetting({'zex_msg_order_trade': value ? 1 : 0});
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
