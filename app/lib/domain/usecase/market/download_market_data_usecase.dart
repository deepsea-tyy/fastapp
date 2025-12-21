import '../../../core/domain/usecase/use_case.dart';
import '../../entity/market/market_data_config.dart';
import '../../repository/market_repository.dart';

/// 下载市场数据配置 UseCase
/// 负责下载并缓存市场数据配置（币种、现货、合约、期权）
class DownloadMarketDataUseCase implements UseCase<MarketDataConfig, void> {
  final MarketRepository _marketRepository;

  DownloadMarketDataUseCase(this._marketRepository);

  @override
  Future<MarketDataConfig> call({required params}) async {
    return await _marketRepository.downloadMarketData();
  }
}

