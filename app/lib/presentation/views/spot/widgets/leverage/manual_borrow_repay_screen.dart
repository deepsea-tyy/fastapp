import 'package:fastapp/constants/app_config.dart';
import 'package:flutter/material.dart';

/// 手动借款/还款页面
class ManualBorrowRepayScreen extends StatefulWidget {
  const ManualBorrowRepayScreen({super.key});

  @override
  State<ManualBorrowRepayScreen> createState() => _ManualBorrowRepayScreenState();
}

class _ManualBorrowRepayScreenState extends State<ManualBorrowRepayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _marginMode = '全仓';
  String _selectedPair = 'TON/USDT';
  String _selectedCurrency = 'USDT';

  // 样式常量
  static const _sectionLabelStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
  );

  static const _selectorTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
  );

  static final _infoTextStyleGrey = TextStyle(
    fontSize: 14,
    color: Colors.grey.shade700,
    height: 1.4,
  );

  static final _boxDecoration = BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(8),
  );

  static final _buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.amber,
    foregroundColor: Colors.black87,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMarginModeButton('全仓', isSelected: _marginMode == '全仓'),
            const SizedBox(width: 16),
            _buildMarginModeButton('逐仓', isSelected: _marginMode == '逐仓'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time, color: Colors.black87),
            onPressed: () {
              // TODO: 显示历史记录
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 标签页
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              indicatorWeight: 2,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: '手动借款'),
                Tab(text: '手动还款'),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBorrowContent(),
                _buildRepayContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginModeButton(String text, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _marginMode = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBorrowContent() {
    return _buildContent(
      label: '逐仓币对',
      selector: _buildPairSelector(),
      infoMessage: '您的逐仓杠杆账户 $_selectedPair 目前没有资产,请先进行划转。',
      buttonText: '划转',
      onButtonPressed: () {
        // TODO: 处理划转
      },
    );
  }

  Widget _buildPairSelector() {
    return _buildSelector(
      child: Row(
        children: [
          Expanded(
            child: Text(_selectedPair, style: _selectorTextStyle),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 24),
        ],
      ),
      onTap: () {
        // TODO: 显示币对选择
      },
    );
  }

  Widget _buildRepayContent() {
    return _buildContent(
      label: '还款数量',
      selector: _buildCurrencySelector(),
      infoMessage: '您还未借过 $_selectedCurrency。',
      buttonText: '立即借款',
      infoIconColor: Colors.orange.shade300,
      onButtonPressed: () => _tabController.animateTo(0),
    );
  }

  Widget _buildCurrencySelector() {
    return _buildSelector(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(_selectedCurrency, style: _selectorTextStyle),
          const SizedBox(width: 8),
          Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
          const Spacer(),
          Text(
            '无需还款',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
      onTap: () {
        // TODO: 显示币种选择
      },
    );
  }

  Widget _buildContent({
    required String label,
    required Widget selector,
    required String infoMessage,
    required String buttonText,
    required VoidCallback onButtonPressed,
    Color? infoIconColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _sectionLabelStyle),
          const SizedBox(height: 8),
          selector,
          const SizedBox(height: 16),
          _buildInfoBox(infoMessage, iconColor: infoIconColor),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: _buttonStyle,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: _boxDecoration,
        child: child,
      ),
    );
  }

  Widget _buildInfoBox(String message, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: iconColor ?? Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: _infoTextStyleGrey),
          ),
        ],
      ),
    );
  }
}

