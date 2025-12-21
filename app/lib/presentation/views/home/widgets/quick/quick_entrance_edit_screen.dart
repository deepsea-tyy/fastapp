import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'service_item_model.dart';
import 'service_repository.dart';
import 'quick_entrance_state.dart';

/// 快捷入口编辑页面
/// 允许用户选择要显示在首页的快捷入口
class QuickEntranceEditScreen extends StatefulWidget {
  const QuickEntranceEditScreen({super.key});

  @override
  State<QuickEntranceEditScreen> createState() => _QuickEntranceEditScreenState();
}

class _QuickEntranceEditScreenState extends State<QuickEntranceEditScreen> {
  final List<String> _selectedIds = [];
  late QuickEntranceState _state;

  @override
  void initState() {
    super.initState();
    _state = context.read<QuickEntranceState>();
    _selectedIds.addAll(_state.quickEntranceIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('编辑快捷入口'),
        actions: [
          TextButton(
            onPressed: _resetToDefault,
            child: const Text('恢复默认', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: _saveChanges,
            child: const Text('保存', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildServiceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '已选择 ${_selectedIds.length}/${QuickEntranceState.maxQuickEntrances}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    return ListView(
      children: [
        _buildServiceSection('常用功能', ServiceRepository.getCommonServices()),
        _buildServiceSection('活动和奖励', ServiceRepository.getActivityServices()),
        _buildServiceSection('交易', ServiceRepository.getTradeServices()),
        _buildServiceSection('理财', ServiceRepository.getFinanceServices()),
      ],
    );
  }

  Widget _buildServiceSection(String title, List<AppServiceItem> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          color: Colors.white,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) => _buildServiceItem(services[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(AppServiceItem service) {
    final isSelected = _selectedIds.contains(service.id);
    final canSelect = _selectedIds.length < QuickEntranceState.maxQuickEntrances;
    final isDisabled = !isSelected && !canSelect && service.canBeQuickEntrance;

    return GestureDetector(
      onTap: service.canBeQuickEntrance
          ? () => _toggleSelection(service.id)
          : null,
      child: Opacity(
        opacity: !service.canBeQuickEntrance || isDisabled ? 0.4 : 1.0,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    service.icon,
                    size: 28,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        // 检查是否达到最小数量
        if (_selectedIds.length <= QuickEntranceState.minQuickEntrances) {
          MessageService.warning('至少需要保留 ${QuickEntranceState.minQuickEntrances} 个快捷入口');
          return;
        }
        _selectedIds.remove(id);
      } else if (_selectedIds.length < QuickEntranceState.maxQuickEntrances) {
        _selectedIds.add(id);
      } else {
        MessageService.warning('最多只能选择 ${QuickEntranceState.maxQuickEntrances} 个快捷入口');
      }
    });
  }

  Future<void> _saveChanges() async {
    // 检查数量限制
    if (_selectedIds.length < QuickEntranceState.minQuickEntrances) {
      MessageService.warning('至少需要选择 ${QuickEntranceState.minQuickEntrances} 个快捷入口');
      return;
    }
    if (_selectedIds.length > QuickEntranceState.maxQuickEntrances) {
      MessageService.warning('最多只能选择 ${QuickEntranceState.maxQuickEntrances} 个快捷入口');
      return;
    }

    try {
      await _state.updateQuickEntrances(_selectedIds);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      MessageService.error('保存失败: $e');
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await MessageService.confirm(
      title: '恢复默认',
      message: '确定要恢复默认的快捷入口设置吗？',
      onConfirm: () {
        setState(() {
          _selectedIds.clear();
          _selectedIds.addAll(ServiceRepository.getDefaultQuickEntranceIds());
        });
      },
    );
  }
}

