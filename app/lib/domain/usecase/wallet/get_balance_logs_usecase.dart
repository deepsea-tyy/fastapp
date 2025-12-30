import '../../../core/domain/usecase/use_case.dart';
import '../../entity/wallet/balance_log.dart';
import '../../repository/wallet_repository.dart';

/// 获取余额日志列表的参数
class GetBalanceLogsParams {
  final String? walletType;
  final String? symbol;
  final String? changeType;
  final int? startTime;
  final int? endTime;
  final int page;
  final int pageSize;

  GetBalanceLogsParams({
    this.walletType,
    this.symbol,
    this.changeType,
    this.startTime,
    this.endTime,
    this.page = 1,
    this.pageSize = 20,
  });
}

/// 获取余额日志列表UseCase
class GetBalanceLogsUseCase
    implements UseCase<List<BalanceLog>, GetBalanceLogsParams> {
  final WalletRepository _walletRepository;

  GetBalanceLogsUseCase(this._walletRepository);

  @override
  Future<List<BalanceLog>> call({required GetBalanceLogsParams params}) async {
    return _walletRepository.getBalanceLogs(
      walletType: params.walletType,
      symbol: params.symbol,
      changeType: params.changeType,
      startTime: params.startTime,
      endTime: params.endTime,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
