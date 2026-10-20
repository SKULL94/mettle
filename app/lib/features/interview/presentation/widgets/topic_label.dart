import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/question.dart';

String topicLabel(InterviewTopic topic) => switch (topic) {
  InterviewTopic.stateManagement => AppStrings.topicStateManagement,
  InterviewTopic.widgetLifecycle => AppStrings.topicWidgetLifecycle,
  InterviewTopic.keys => AppStrings.topicKeys,
  InterviewTopic.asyncIsolates => AppStrings.topicAsyncIsolates,
  InterviewTopic.performance => AppStrings.topicPerformance,
  InterviewTopic.navigation => AppStrings.topicNavigation,
  InterviewTopic.testing => AppStrings.topicTesting,
};

String followUpReasonLabel(FollowUpReason reason) => switch (reason) {
  FollowUpReason.depth => AppStrings.reasonDepth,
  FollowUpReason.correctness => AppStrings.reasonCorrectness,
  FollowUpReason.clarity => AppStrings.reasonClarity,
  FollowUpReason.structure => AppStrings.reasonStructure,
};
