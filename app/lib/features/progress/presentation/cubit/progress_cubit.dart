import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_progress_overview.dart';
import '../../domain/usecases/watch_sessions.dart';
import 'progress_state.dart';

final class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._getOverview, WatchSessions watchSessions)
    : super(const ProgressLoading()) {
    _changes = watchSessions(const NoParams()).listen((_) => load());
  }

  final GetProgressOverview _getOverview;

  late final StreamSubscription<void> _changes;

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }

  Future<void> load() async {
    emit(const ProgressLoading());

    final result = await _getOverview(const NoParams());
    if (isClosed) return;

    emit(switch (result) {
      Success(:final data) when data.isEmpty => const ProgressEmpty(),
      Success(:final data) => ProgressLoaded(data),
      Failed(:final failure) => ProgressError(failure.message),
    });
  }
}
