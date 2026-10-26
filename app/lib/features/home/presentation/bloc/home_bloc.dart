import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_home_overview.dart';
import '../../domain/usecases/watch_sessions.dart';
import 'home_event.dart';
import 'home_state.dart';

final class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._getOverview, WatchSessions watchSessions)
    : super(const HomeInitial()) {
    on<HomeRequested>(_onRequested);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeErrorDismissed>(_onErrorDismissed);

    _changes = watchSessions(const NoParams())
        .listen((_) => add(const HomeRefreshed()));
  }

  final GetHomeOverview _getOverview;

  late final StreamSubscription<void> _changes;

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }

  Future<void> _onRequested(
    HomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    emit(await _load(fallback: null));
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    final previous = state;
    emit(await _load(fallback: previous is HomeLoaded ? previous : null));
  }

  void _onErrorDismissed(HomeErrorDismissed event, Emitter<HomeState> emit) {
    final current = state;
    if (current is HomeLoaded) emit(current.withWarning(null));
  }

  Future<HomeState> _load({required HomeLoaded? fallback}) async {
    final result = await _getOverview(const NoParams());

    return switch (result) {
      Success(:final data) when data.isEmpty => const HomeEmpty(),
      Success(:final data) => HomeLoaded(data),

      Failed(:final failure) when fallback != null => fallback.withWarning(
        failure.message,
      ),
      Failed(:final failure) => HomeError(failure.message),
    };
  }
}
