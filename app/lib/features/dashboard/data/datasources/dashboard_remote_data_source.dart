import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_summary.dart';
import '../models/user_summary_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<UserSummary> summary();
}

final class DashboardHttpDataSource implements DashboardRemoteDataSource {
  const DashboardHttpDataSource(this._client);

  final ApiClient _client;

  @override
  Future<UserSummary> summary() async {
    final json = await _client.getJson(ApiConstants.summary);
    return UserSummaryModel.fromJson(json);
  }
}
