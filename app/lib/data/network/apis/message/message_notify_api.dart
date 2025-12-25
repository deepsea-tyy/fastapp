import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// 消息通知API
class MessageNotifyApi {
  final DioClient _dioClient;

  MessageNotifyApi(this._dioClient);

  /// 获取消息列表
  /// [notifyType] 通知分类:1-系统通知,2-业务通知,3-其他
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<Map<String, dynamic>> getMessageList({
    int? notifyType,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (notifyType != null) {
      queryParams['notify_type'] = notifyType;
    }

    final response = await _dioClient.dio.get(
      Endpoints.messageNotifyList,
      queryParameters: queryParams,
    );

    return response.data;
  }

  /// 更新已读状态
  /// [notifyType] 通知分类:1-系统通知,2-业务通知,3-其他
  /// [notifyId] 通知id
  Future<Map<String, dynamic>> updateReadStatus({
    required int notifyType,
    required int notifyId,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.messageNotifyRead,
      data: {
        'notify_type': notifyType,
        'notify_id': notifyId,
      },
    );

    return response.data;
  }

  /// 获取分类未读统计
  Future<Map<String, dynamic>> getUnreadStatistics() async {
    final response = await _dioClient.dio.get(
      Endpoints.messageNotifyUnreadStatistics,
    );

    return response.data;
  }

  /// 获取总未读数
  Future<int> getUnreadTotal() async {
    final response = await _dioClient.dio.get(
      Endpoints.messageNotifyUnreadTotal,
    );

    return response.data['total'] ?? 0;
  }

  /// 清除未读消息
  /// [notifyType] 通知分类:1-公告,2-活动,3-账户,4-广场,5-交易。不传则清除所有分类
  Future<Map<String, dynamic>> clearUnread({int? notifyType}) async {
    final data = <String, dynamic>{};
    if (notifyType != null) {
      data['notify_type'] = notifyType;
    }

    final response = await _dioClient.dio.post(
      Endpoints.messageNotifyClearUnread,
      data: data,
    );

    return response.data;
  }
}
