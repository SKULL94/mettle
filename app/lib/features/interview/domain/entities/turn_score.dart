class TurnScore {
  const TurnScore({
    required this.correctness,
    required this.depth,
    required this.clarity,
    required this.structure,
    this.missing = const <String>[],
  });

  final int correctness;
  final int depth;
  final int clarity;
  final int structure;
  final List<String> missing;

  int get overall {
    const dimensions = 4;
    const maxPerDimension = 5;
    final total = correctness + depth + clarity + structure;
    return (total / (dimensions * maxPerDimension) * 100).round();
  }

  int get weakest =>
      [correctness, depth, clarity, structure].reduce((a, b) => a < b ? a : b);
}
