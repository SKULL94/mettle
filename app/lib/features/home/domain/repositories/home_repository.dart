import '../../../../core/result/result.dart';
import '../entities/home_overview.dart';

abstract interface class HomeRepository {
  Stream<void> watchSessions();

  Future<Result<HomeOverview>> getOverview();
}
