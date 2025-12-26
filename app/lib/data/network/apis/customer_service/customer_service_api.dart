import '../../../../core/data/network/dio/dio_client.dart';

class CustomerServiceApi {
  final DioClient _dioClient;

  CustomerServiceApi(this._dioClient);

  Future<Map<String, dynamic>> getConversation() async {
    final response = await _dioClient.dio.get('/api/sysKefu/message/getConversation');
    return response.data;
  }

  Future<List<dynamic>> getMessages({
    required int conversationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get('/api/sysKefu/message/list', queryParameters: {
      'conversation_id': conversationId,
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return data['list'] as List<dynamic>;
  }
}
