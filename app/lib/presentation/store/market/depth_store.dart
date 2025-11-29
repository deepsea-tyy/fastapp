import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart' as depth_usecase;
import 'package:mobx/mobx.dart';

part 'depth_store.g.dart';

class DepthStore = _DepthStore with _$DepthStore;

abstract class _DepthStore with Store {
  final GetDepthUseCase _getDepthUseCase;
  final ErrorStore _errorStore;

  _DepthStore(
    this._getDepthUseCase,
    this._errorStore,
  );

  // 深度图数据
  @observable
  DepthChartData? depthData;

  // 当前交易对
  @observable
  String currentSymbol = 'BTC/USDT';

  // 是否正在加载
  @observable
  bool isLoading = false;

  // 错误消息
  @observable
  String? errorMessage;

  // Actions
  @action
  void setCurrentSymbol(String symbol) {
    currentSymbol = symbol;
  }

  @action
  Future<void> loadDepthData({int? limit}) async {
    isLoading = true;
    errorMessage = null;

    try {
      final data = await _getDepthUseCase.call(
        params: depth_usecase.GetDepthParams(
          symbol: currentSymbol,
          limit: limit,
        ),
      );
      depthData = data;
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refreshDepthData() async {
    await loadDepthData();
  }

  void dispose() {}
}

