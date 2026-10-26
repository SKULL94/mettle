enum Difficulty {
  easy('easy', 'Easy', 'Junior'),
  medium('medium', 'Medium', 'Mid-level'),
  hard('hard', 'Hard', 'Senior');

  const Difficulty(this.id, this.label, this.seniority);

  final String id;
  final String label;
  final String seniority;

  static const defaultLevel = Difficulty.medium;

  static Difficulty fromId(String id) => Difficulty.values.firstWhere(
    (level) => level.id == id,
    orElse: () => defaultLevel,
  );
}
