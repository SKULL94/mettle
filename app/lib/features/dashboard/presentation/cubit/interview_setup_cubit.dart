import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../domain/entities/user_summary.dart';

const questionCounts = <int>[3, 5, 10];
const questionMinutes = <int, int>{3: 10, 5: 18, 10: 35};
const proQuestionCount = 10;
const quickCheckQuestions = 3;
const quickCheckMinutes = 10;

@immutable
final class InterviewSetup {
  const InterviewSetup({
    this.mode = InterviewMode.quickCheck,
    this.level = Level.mid,
    this.topicId,
    this.questionCount = 5,
  });

  final InterviewMode mode;
  final Level level;
  final String? topicId;
  final int questionCount;

  bool get isQuickCheck => mode == InterviewMode.quickCheck;

  bool get canContinue => isQuickCheck || topicId != null;

  int get effectiveCount => isQuickCheck ? quickCheckQuestions : questionCount;

  int get minutes => isQuickCheck
      ? quickCheckMinutes
      : questionMinutes[questionCount] ?? quickCheckMinutes;

  InterviewSetup copyWith({
    InterviewMode? mode,
    Level? level,
    String? topicId,
    int? questionCount,
  }) {
    return InterviewSetup(
      mode: mode ?? this.mode,
      level: level ?? this.level,
      topicId: topicId ?? this.topicId,
      questionCount: questionCount ?? this.questionCount,
    );
  }
}

final class InterviewSetupCubit extends Cubit<InterviewSetup> {
  InterviewSetupCubit() : super(InterviewSetup(level: _storedLevel()));

  static Level _storedLevel() =>
      Level.fromId(sl<AppPreferences>().level() ?? Level.fallback.id);

  void setMode(InterviewMode mode) => emit(state.copyWith(mode: mode));

  void setLevel(Level level) {
    emit(state.copyWith(level: level));
    unawaited(sl<AppPreferences>().setLevel(level.id));
  }

  void setTopic(String topicId) =>
      emit(state.copyWith(mode: InterviewMode.topic, topicId: topicId));

  void setQuestionCount(int count) =>
      emit(state.copyWith(questionCount: count));
}
