import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_summary.dart';
import 'dashboard_state.dart';

final class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getSummary) : super(const DashboardLoading());

  final GetSummary _getSummary;

  Future<void> load() async {
    final previous = state;
    if (previous is! DashboardLoaded) emit(const DashboardLoading());

    final result = await _getSummary(const NoParams());
    if (isClosed) return;

    emit(switch (result) {
      Success(:final data) => DashboardLoaded(data),
      Failed(:final failure) when previous is DashboardLoaded =>
        previous.withWarning(failure.message),
      Failed(:final failure) => DashboardError(failure.message),
    });
  }

  void dismissWarning() {
    final current = state;
    if (current is DashboardLoaded) emit(current.withWarning(null));
  }
}
