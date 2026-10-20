import '../../../../core/result/result.dart';
import '../entities/home_overview.dart';

abstract interface class HomeRepository {
  Future<Result<HomeOverview>> getOverview();
}
