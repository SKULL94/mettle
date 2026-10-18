import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/usecases/get_scorecard.dart';
import 'scorecard_state.dart';

final class ScorecardCubit extends Cubit<ScorecardState> {
  ScorecardCubit({required this.sessionId, required this.getScorecard})
    : super(const ScorecardLoading());

  final String sessionId;
  final GetScorecard getScorecard;

  Future<void> load() async {
    emit(const ScorecardLoading());
    final result = await getScorecard(sessionId);
    if (isClosed) return;

    emit(switch (result) {
      Success(:final data) => ScorecardLoaded(data),
      Failed(:final failure) => ScorecardError(failure.message),
    });
  }
}
