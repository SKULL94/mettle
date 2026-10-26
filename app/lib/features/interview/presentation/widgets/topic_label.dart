import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/interview_topic.dart';
import '../../domain/entities/question.dart';

String topicLabel(InterviewTopic topic) => topic.label;

String followUpReasonLabel(FollowUpReason reason) => switch (reason) {
  FollowUpReason.depth => AppStrings.reasonDepth,
  FollowUpReason.correctness => AppStrings.reasonCorrectness,
  FollowUpReason.clarity => AppStrings.reasonClarity,
  FollowUpReason.structure => AppStrings.reasonStructure,
};
