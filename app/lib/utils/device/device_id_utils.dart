/// 设备唯一标识工具类
/// 
/// 功能说明：
/// - 所有平台统一使用 UUID v4 + 本地存储方案
/// - iOS/Android: 使用 SharedPreferences 存储 UUID
/// - Web: 使用 localStorage 存储 UUID
/// 
/// 使用场景：
/// - 登录时传递设备标识，用于设备管理和安全控制
/// - 支持多平台统一接口，自动识别平台并返回对应标识
/// 
/// 实现方案：
/// - 首次使用时生成 UUID v4 格式的设备标识
/// - 存储到本地（SharedPreferences/localStorage）
/// - 后续直接读取存储的标识
/// - 清除应用数据/浏览器数据后，会生成新的标识
/// 
/// 优点：
/// - 简单统一，无需外部依赖
/// - 打包大小最小，编译速度快
/// - 无权限要求，不依赖系统API
/// 
/// 注意事项：
/// - 不是真实的设备硬件标识
/// - 清除应用数据后会改变
/// - 卸载重装后会改变（除非使用 Keychain/iCloud）
import 'dart:math';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';

class DeviceIdUtils {
  /// 获取设备唯一标识
  ///
  /// 返回值：
  /// - 格式: UUID v4 格式字符串（如：550e8400-e29b-41d4-a716-446655440000）
  /// - 首次调用时生成并存储，后续调用直接返回存储的值
  ///
  /// 异常处理：
  /// - 如果存储失败，返回临时 UUID（仅本次会话有效）
  /// - 如果获取失败，返回空字符串，不影响登录流程
  static Future<String> getDeviceId() async {
    try {
      final sharedPrefHelper = getIt<SharedPreferenceHelper>();
      String? deviceId = await sharedPrefHelper.deviceId;

      if (deviceId == null || deviceId.isEmpty) {
        // 生成新的 UUID
        deviceId = _generateUUID();
        // 保存到本地存储
        await sharedPrefHelper.saveDeviceId(deviceId);
      }

      return deviceId;
    } catch (e) {
      // 存储失败时，返回临时 UUID（仅本次会话有效）
      return _generateUUID();
    }
  }

  /// 保存设备唯一标识
  ///
  /// 当后端返回设备ID时，使用后端返回的ID更新本地存储
  /// 这样可以确保前后端使用相同的设备标识
  static Future<bool> saveDeviceId(String deviceId) async {
    try {
      final sharedPrefHelper = getIt<SharedPreferenceHelper>();
      return await sharedPrefHelper.saveDeviceId(deviceId);
    } catch (e) {
      return false;
    }
  }

  /// 生成 UUID v4 格式的字符串
  /// 
  /// 格式：xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  /// 其中 x 是十六进制数字，y 是 8、9、A 或 B
  /// 
  /// UUID v4 是随机生成的 UUID，用于设备标识
  static String _generateUUID() {
    final random = Random();
    
    // 生成指定长度的十六进制字符串
    String generateHex(int length) {
      return List.generate(
        length,
        (_) => random.nextInt(16).toRadixString(16),
      ).join();
    }
    
    // UUID v4 格式：xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    // 版本号（第13位）固定为 4
    // 变体（第17位）为 8、9、a 或 b
    final part1 = generateHex(8);
    final part2 = generateHex(4);
    final part3 = '4${generateHex(3)}'; // 版本号 4
    final variant = ['8', '9', 'a', 'b'][random.nextInt(4)];
    final part4 = '$variant${generateHex(3)}';
    final part5 = generateHex(12);
    
    return '$part1-$part2-$part3-$part4-$part5';
  }
}
