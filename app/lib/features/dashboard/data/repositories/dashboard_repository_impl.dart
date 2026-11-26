import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

final class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<Result<UserSummary>> getSummary() async {
    try {
      return Success(await _remote.summary());
    } on NetworkException catch (error) {
      return Failed(
        NetworkFailure(error.detail ?? AppStrings.serverUnreachable),
      );
    } on ServerException catch (error) {
      return Failed(ServerFailure(error.detail ?? AppStrings.serverError));
    } on Object {
      return const Failed(UnknownFailure());
    }
  }
}
