import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_item_model.dart';
import 'service_repository.dart';

/// 快捷入口状态管理
/// 管理用户自定义的快捷入口配置，支持持久化存储
class QuickEntranceState extends ChangeNotifier {
  static const String _storageKey = 'quick_entrance_ids';
  static const int maxQuickEntrances = 10; // 最多10个快捷入口
  static const int minQuickEntrances = 5; // 至少3个快捷入口

  List<String> _quickEntranceIds = [];
  final decorationConfigs = {
    0: {'color': Colors.orange.shade300, 'position': const Alignment(-0.6, -0.6), 'type': 'dot', 'size': 8.0},
    1: {'color': Colors.orange.shade300, 'position': const Alignment(0, -0.8), 'type': 'dot', 'size': 12.0},
    2: {'color': Colors.orange.shade300, 'position': const Alignment(0, -0.8), 'type': 'rays', 'size': 8.0},
    3: {'color': Colors.orange.shade300, 'position': const Alignment(0.6, -0.6), 'type': 'plus', 'size': 8.0},
    4: {'color': Colors.orange.shade300, 'position': const Alignment(0.3, -0.3), 'type': 'grid', 'size': 8.0},
  };

  QuickEntranceState() {
    _loadQuickEntrances();
  }

  /// 获取快捷入口ID列表
  List<String> get quickEntranceIds => List.unmodifiable(_quickEntranceIds);

  /// 获取快捷入口服务项列表（带装饰）
  List<AppServiceItem> getQuickEntrances() {
    return _quickEntranceIds
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final id = entry.value;
          final service = ServiceRepository.getServiceById(id);
          if (service == null) return null;

          final config = decorationConfigs[index];
          return config != null
              ? service.withDecoration(
                  decorationColor: config['color'] as Color?,
                  decorationPosition: config['position'] as Alignment?,
                  decorationType: config['type'] as String?,
                  decorationSize: config['size'] as double?,
                )
              : service;
        })
        .whereType<AppServiceItem>()
        .toList();
  }

  /// 从本地存储加载快捷入口配置
  Future<void> _loadQuickEntrances() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList(_storageKey);

      if (savedIds != null && savedIds.isNotEmpty) {
        _quickEntranceIds = savedIds;
      } else {
        // 使用默认配置
        _quickEntranceIds = ServiceRepository.getDefaultQuickEntranceIds();
      }

      notifyListeners();
    } catch (e) {
      // 加载失败，使用默认配置
      _quickEntranceIds = ServiceRepository.getDefaultQuickEntranceIds();
      notifyListeners();
    }
  }

  /// 保存快捷入口配置到本地存储
  Future<void> _saveQuickEntrances() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _quickEntranceIds);
    } catch (e) {
      debugPrint('保存快捷入口配置失败: $e');
    }
  }

  /// 更新快捷入口列表
  Future<void> updateQuickEntrances(List<String> ids) async {
    if (ids.length > maxQuickEntrances) {
      throw Exception('快捷入口数量不能超过 $maxQuickEntrances 个');
    }
    if (ids.length < minQuickEntrances) {
      throw Exception('快捷入口数量不能少于 $minQuickEntrances 个');
    }

    _quickEntranceIds = ids;
    await _saveQuickEntrances();
    notifyListeners();
  }

  /// 重置为默认配置
  Future<void> resetToDefault() async {
    _quickEntranceIds = ServiceRepository.getDefaultQuickEntranceIds();
    await _saveQuickEntrances();
    notifyListeners();
  }
}

