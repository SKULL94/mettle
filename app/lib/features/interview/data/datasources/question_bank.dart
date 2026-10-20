import '../../domain/entities/interview_topic.dart';

class ScriptedQuestion {
  const ScriptedQuestion({
    required this.text,
    required this.keywords,
    required this.followUp,
  });

  final String text;
  final List<String> keywords;
  final String followUp;
}

abstract final class QuestionBank {
  static List<ScriptedQuestion> forTopic(InterviewTopic topic) =>
      _bank[topic] ?? _bank[InterviewTopic.stateManagement]!;

  static const _bank = <InterviewTopic, List<ScriptedQuestion>>{
    InterviewTopic.stateManagement: [
      ScriptedQuestion(
        text:
            'You have a bloc that rebuilds a list on every keystroke in a search '
            'field. Walk me through what you would change and why.',
        keywords: [
          'debounce',
          'buildwhen',
          'transformer',
          'rebuild',
          'equatable',
        ],
        followUp:
            'You mentioned reducing rebuilds. What exactly does buildWhen compare, '
            'and what breaks if your state class has no value equality?',
      ),
      ScriptedQuestion(
        text:
            'When would you reach for a Cubit instead of a Bloc, and what do you '
            'give up by doing so?',
        keywords: ['event', 'traceability', 'simple', 'transformer', 'audit'],
        followUp:
            'If events are documentation, what do you lose in debugging once a '
            'Cubit replaces them?',
      ),
      ScriptedQuestion(
        text:
            'A bloc needs data from two repositories that can each fail '
            'independently. How do you model that state?',
        keywords: ['sealed', 'partial', 'failure', 'union', 'copywith'],
        followUp:
            'How does your model distinguish "still loading the second source" '
            'from "the second source failed"?',
      ),
    ],
    InterviewTopic.widgetLifecycle: [
      ScriptedQuestion(
        text:
            'Why is it wrong to call an async API directly inside build(), and '
            'where should that call go instead?',
        keywords: [
          'initstate',
          'rebuild',
          'didchangedependencies',
          'future',
          'idempotent',
        ],
        followUp:
            'initState cannot await. How do you handle a widget disposed before '
            'the future resolves?',
      ),
      ScriptedQuestion(
        text:
            'What is the practical difference between didUpdateWidget and '
            'didChangeDependencies?',
        keywords: [
          'inherited',
          'parent',
          'configuration',
          'oldwidget',
          'theme',
        ],
        followUp:
            'Which of the two fires when the surrounding Theme changes, and why '
            'that one?',
      ),
    ],
    InterviewTopic.keys: [
      ScriptedQuestion(
        text:
            'You reorder a list of stateful rows and the state attaches to the '
            'wrong row. What is happening?',
        keywords: ['key', 'valuekey', 'element', 'canupdate', 'runtimetype'],
        followUp:
            'You mentioned keys. What does canUpdate actually compare, and what '
            'breaks without a ValueKey in a reorderable list?',
      ),
      ScriptedQuestion(
        text: 'When is a GlobalKey the right tool, and what does it cost?',
        keywords: ['globalkey', 'expensive', 'state', 'reparent', 'form'],
        followUp:
            'Why is holding a GlobalKey across a rebuild more expensive than a '
            'local key?',
      ),
    ],
    InterviewTopic.asyncIsolates: [
      ScriptedQuestion(
        text:
            'Parsing a large JSON payload is janking your UI. What do you do, and '
            'what are the constraints?',
        keywords: ['isolate', 'compute', 'sendport', 'serializable', 'jank'],
        followUp:
            'What kinds of objects can cross an isolate boundary, and what '
            'happens if you try to send a closure?',
      ),
      ScriptedQuestion(
        text:
            'Explain the difference between an async gap and a microtask in terms '
            'of when your code actually runs.',
        keywords: ['event loop', 'microtask', 'scheduler', 'await', 'queue'],
        followUp:
            'Given a microtask and a Future.delayed(Duration.zero), which runs '
            'first and why?',
      ),
    ],
    InterviewTopic.performance: [
      ScriptedQuestion(
        text:
            'A scrolling list drops frames on a mid-range Android device. How do '
            'you find the cause rather than guessing?',
        keywords: ['devtools', 'timeline', 'raster', 'repaint', 'const'],
        followUp:
            'You found the slow frames. How do you tell a UI-thread problem from '
            'a raster-thread problem?',
      ),
      ScriptedQuestion(
        text:
            'What does RepaintBoundary actually do, and when does adding one make '
            'things worse?',
        keywords: ['layer', 'repaint', 'memory', 'raster', 'boundary'],
        followUp:
            'If every widget got a RepaintBoundary, what would you expect to '
            'regress?',
      ),
    ],
    InterviewTopic.navigation: [
      ScriptedQuestion(
        text:
            'Your app supports deep links and browser refresh on web. How does '
            'that constrain what you pass between routes?',
        keywords: ['identifier', 'path', 'serializable', 'extra', 'refetch'],
        followUp:
            'You said pass identifiers. What specifically breaks on a browser '
            'refresh if you pass an object instead?',
      ),
      ScriptedQuestion(
        text:
            'How do you keep per-tab navigation stacks independent in a bottom '
            'navigation app?',
        keywords: ['shell', 'indexedstack', 'branch', 'navigator', 'state'],
        followUp:
            'What happens to the other tabs state when you rebuild the shell '
            'route?',
      ),
    ],
    InterviewTopic.testing: [
      ScriptedQuestion(
        text:
            'What do you assert in a bloc test that you would not assert in a '
            'widget test, and why keep them separate?',
        keywords: ['sequence', 'emit', 'render', 'pump', 'isolation'],
        followUp:
            'Your bloc test passes but the screen is blank. Which test was '
            'missing?',
      ),
      ScriptedQuestion(
        text:
            'Golden tests keep failing in CI but pass locally. What are the likely '
            'causes?',
        keywords: ['font', 'platform', 'shader', 'tolerance', 'ci'],
        followUp:
            'How would you make the goldens deterministic without weakening what '
            'they catch?',
      ),
    ],
  };
}
