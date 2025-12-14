import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// 附件上传API实现
class AttachmentApi {
  final DioClient _dioClient;

  /// 最大文件大小（3MB）
  static const int maxFileSize = 3 * 1024 * 1024;

  AttachmentApi(this._dioClient);

  /// 上传附件
  /// [filePath] 文件本地路径
  /// [fileName] 文件名（可选，如果不提供则使用文件路径的文件名）
  /// [onSendProgress] 上传进度回调
  ///
  /// 抛出异常:
  /// - 文件大小超过 3MB 时抛出异常
  Future<Map<String, dynamic>> upload({
    required String filePath,
    String? fileName,
    ProgressCallback? onSendProgress,
  }) async {
    // 检查文件是否存在
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在');
    }

    // 检查文件大小
    final fileSize = await file.length();
    if (fileSize > maxFileSize) {
      final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      throw Exception('文件大小超过限制，当前文件: ${sizeMB}MB，最大限制: 3MB');
    }

    // 从文件路径提取文件名
    final fileNameToUse = fileName ?? filePath.split('/').last;

    // 创建 FormData
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileNameToUse,
      ),
    });

    final response = await _dioClient.dio.post(
      Endpoints.attachmentUpload,
      data: formData,
      onSendProgress: onSendProgress,
    );

    return response.data;
  }

  /// 获取附件列表
  /// [page] 页码（可选，默认1）
  /// [pageSize] 每页数量（可选，默认20）
  Future<Map<String, dynamic>> list({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.attachmentList,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    return response.data;
  }

  /// 删除附件
  /// [id] 附件ID
  Future<Map<String, dynamic>> delete(int id) async {
    final response = await _dioClient.dio.delete(
      '${Endpoints.attachmentDelete}/$id',
    );

    return response.data;
  }
}
