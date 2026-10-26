import 'difficulty.dart';

enum InterviewTopic {
  fundamentals(
    'fundamentals',
    Difficulty.easy,
    'Flutter & Dart Fundamentals',
    'Stateless vs Stateful, final, const and static',
  ),
  widgetsLifecycle(
    'widgets-lifecycle',
    Difficulty.easy,
    'Widgets & Lifecycle',
    'The widget tree, BuildContext, initState and dispose',
  ),
  layouts(
    'layouts',
    Difficulty.easy,
    'Basic UI & Layouts',
    'Row, Column, Container and axis alignment',
  ),
  navigationBasics(
    'navigation-basics',
    Difficulty.easy,
    'Navigation',
    'Navigator.push and Navigator.pop',
  ),
  asyncBasics(
    'async-basics',
    Difficulty.easy,
    'Asynchronous Basics',
    'Future, Stream and async/await',
  ),
  simpleState(
    'simple-state',
    Difficulty.easy,
    'Simple State Management',
    'setState for local state, a first look at Provider',
  ),

  stateManagement(
    'state-management',
    Difficulty.medium,
    'State Management in Depth',
    'Provider, Riverpod, BLoC and GetX compared',
  ),
  architecture(
    'architecture',
    Difficulty.medium,
    'Architecture & Patterns',
    'MVVM, Clean Architecture, separating concerns',
  ),
  networking(
    'networking',
    Difficulty.medium,
    'Networking & Data',
    'http and Dio, JSON parsing, loading and error states',
  ),
  localStorage(
    'local-storage',
    Difficulty.medium,
    'Local Storage',
    'SharedPreferences, SQLite, Hive and Isar',
  ),
  advancedWidgets(
    'advanced-widgets',
    Difficulty.medium,
    'Advanced Widgets & UI',
    'FutureBuilder, ListView.builder, keys, custom widgets',
  ),
  testing(
    'testing',
    Difficulty.medium,
    'Testing',
    'Unit tests, widget tests and mocking',
  ),
  intermediateDart(
    'intermediate-dart',
    Difficulty.medium,
    'Intermediate Dart',
    'Mixins, extension methods and the mounted check',
  ),

  modularization(
    'modularization',
    Difficulty.hard,
    'Advanced Architecture & Modularization',
    'Scaling a codebase into packages, Melos, team boundaries',
  ),
  performanceEngineering(
    'performance-engineering',
    Difficulty.hard,
    'Performance Engineering',
    'Profile mode, frame timing, memory, Impeller, perf in CI',
  ),
  concurrency(
    'concurrency',
    Difficulty.hard,
    'Concurrency & Isolates',
    "Dart's concurrency model and when an isolate earns its cost",
  ),
  platformChannels(
    'platform-channels',
    Difficulty.hard,
    'Native Integration & Platform Channels',
    'Plugins, channels, and the risk a native SDK carries',
  ),
  complexScenarios(
    'complex-scenarios',
    Difficulty.hard,
    'Complex Scenarios',
    'Offline-first sync, large migrations, incident response',
  ),
  testingAtScale(
    'testing-at-scale',
    Difficulty.hard,
    'Testing Strategy at Scale',
    'Strategy for a large team, flaky tests, holding the bar',
  ),
  releaseManagement(
    'release-management',
    Difficulty.hard,
    'CI/CD & Release Management',
    'Pipelines, flavours, automated releases',
  );

  const InterviewTopic(this.id, this.difficulty, this.label, this.covers);

  final String id;
  final Difficulty difficulty;
  final String label;
  final String covers;

  static const fallback = InterviewTopic.stateManagement;

  static List<InterviewTopic> forDifficulty(Difficulty difficulty) => values
      .where((topic) => topic.difficulty == difficulty)
      .toList(growable: false);

  static InterviewTopic fromId(String id) =>
      values.firstWhere((topic) => topic.id == id, orElse: () => fallback);
}
