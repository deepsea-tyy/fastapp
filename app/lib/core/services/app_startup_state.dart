import 'dart:async';
import 'package:flutter/widgets.dart';

/// 应用启动状态管理
/// 用于协调启动时的异步操作顺序
class AppStartupState {
  static bool _pageContentDownloaded = false;
  static final Completer<void> _pageContentCompleter = Completer<void>();

  /// 检查页面内容是否已下载完成
  static bool get isPageContentDownloaded => _pageContentDownloaded;

  /// 等待页面内容下载完成
  /// 如果已完成则立即返回，否则等待完成
  static Future<void> waitForPageContent() async {
    if (_pageContentDownloaded) return;
    return _pageContentCompleter.future;
  }

  /// 标记页面内容下载完成
  /// 应该在 pageContentDownload 完成后调用
  static void markPageContentDownloaded() {
    if (_pageContentDownloaded) return;
    _pageContentDownloaded = true;
    if (!_pageContentCompleter.isCompleted) {
      _pageContentCompleter.complete();
    }
  }
}

/// State 扩展方法，简化等待启动完成的代码
extension StateStartupExtension on State {
  /// 在页面内容下载完成后执行回调
  /// 自动处理 postFrameCallback 和等待逻辑
  void afterPageContentDownloaded(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppStartupState.waitForPageContent();
      if (mounted) {
        callback();
      }
    });
  }

  /// 在页面内容下载完成后执行异步回调
  /// 自动处理 postFrameCallback 和等待逻辑
  void afterPageContentDownloadedAsync(Future<void> Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppStartupState.waitForPageContent();
      if (mounted) {
        await callback();
      }
    });
  }
}

