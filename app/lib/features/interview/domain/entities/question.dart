enum QuestionKind { initial, followUp }

enum FollowUpReason { depth, correctness, clarity, structure }

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.index,
    required this.total,
    this.kind = QuestionKind.initial,
    this.reason,
  });

  final String id;
  final String text;
  final int index;
  final int total;
  final QuestionKind kind;
  final FollowUpReason? reason;

  bool get isFollowUp => kind == QuestionKind.followUp;
}
