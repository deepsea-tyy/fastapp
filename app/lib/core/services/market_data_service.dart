import 'dart:io';
import 'dart:convert';
import 'package:fastapp/data/network/apis/market/market_api.dart';
import 'package:fastapp/domain/entity/market/market_data_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 市场数据服务
/// 负责下载和缓存市场数据配置（币种、现货、合约、期权）
class MarketDataService {
  final MarketApi _marketApi;
  static const String _fileName = 'market-data.json';
  
  bool _isDownloading = false;
  Future<MarketDataConfig?>? _downloadFuture;
  File? _cachedFile;

  MarketDataService(this._marketApi);

  /// 获取市场数据配置
  /// 启动时总是先请求服务器，失败则降级使用本地缓存
  Future<MarketDataConfig?> getMarketData() async {
    // 启动时总是先尝试从服务器下载
    try {
      final config = await downloadAndSave();
      if (config != null) {
        return config;
      }
    } catch (e) {
      // 下载失败，记录错误但继续尝试使用本地缓存
      // 这里不抛出异常，而是降级到本地数据
    }
    
    // 下载失败，降级使用本地缓存
    final localConfig = await loadFromLocal();
    if (localConfig != null) {
      return localConfig;
    }
    
    // 如果本地也没有数据，返回 null（让上层处理）
    return null;
  }

  /// 下载并保存市场数据配置
  /// 总是尝试从服务器下载，不检查本地缓存
  Future<MarketDataConfig?> downloadAndSave() async {
    if (_isDownloading && _downloadFuture != null) {
      return _downloadFuture;
    }

    _isDownloading = true;
    _downloadFuture = _performDownload();

    try {
      final result = await _downloadFuture!;
      return result;
    } catch (e) {
      // 下载失败，返回 null，让上层降级到本地数据
      return null;
    } finally {
      _isDownloading = false;
      _downloadFuture = null;
    }
  }

  /// 执行下载操作
  Future<MarketDataConfig?> _performDownload() async {
    try {
      final config = await _marketApi.downloadMarketData();
      await _saveMarketData(config);
      return config;
    } catch (e) {
      rethrow; // 重新抛出异常，让上层知道下载失败
    }
  }

  /// 从本地文件加载配置
  Future<MarketDataConfig?> loadFromLocal() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return MarketDataConfig.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// 保存市场数据到本地
  Future<void> _saveMarketData(MarketDataConfig config) async {
    try {
      final file = await _getLocalFile();
      await file.create(recursive: true);
      final json = jsonEncode(config.toJson());
      await file.writeAsString(json, flush: true);
    } catch (_) {}
  }

  /// 获取本地文件路径
  Future<File> _getLocalFile() async {
    if (_cachedFile != null) {
      return _cachedFile!;
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final configDir = Directory(path.join(directory.path, 'config'));
    await configDir.create(recursive: true);
    final file = File(path.join(configDir.path, _fileName));
    _cachedFile = file;
    return file;
  }

  /// 清除本地缓存
  Future<void> clearCache() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) await file.delete();
      _cachedFile = null;
    } catch (_) {}
  }

  /// 获取本地文件路径
  Future<String?> getLocalFilePath() async {
    try {
      final file = await _getLocalFile();
      return await file.exists() ? file.path : null;
    } catch (_) {
      return null;
    }
  }
}

