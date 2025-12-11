const _kDefaultReceiveTimeout = 5000;
const _kDefaultConnectionTimeout = 5000;
const _kDefaultSendTimeout = 5000;

class DioConfigs {
  final String baseUrl;
  final int receiveTimeout;
  final int connectionTimeout;
  final int sendTimeout;

  const DioConfigs({
    required this.baseUrl,
    this.receiveTimeout = _kDefaultReceiveTimeout,
    this.connectionTimeout = _kDefaultConnectionTimeout,
    this.sendTimeout = _kDefaultSendTimeout,
  });
}
