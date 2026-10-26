class ScoreDelta {
  const ScoreDelta(this.points);

  final int points;

  bool get isUp => points > 0;
  bool get isFlat => points == 0;
}
