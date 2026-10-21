const List<Map<String, dynamic>> sessionSeed = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'seed-state-management',
    'topic': 'state-management',
    'completed_at': '2026-10-12T18:04:00.000Z',
    'turns': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'seed-sm-1',
        'question':
            'You have a bloc that rebuilds a list on every keystroke in a '
            'search field. Walk me through what you would change and why.',
        'index': 1,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'I would debounce the search events with a transformer so the '
            'bloc only reacts once the user pauses typing.',
        'score': <String, dynamic>{
          'correctness': 4,
          'depth': 3,
          'clarity': 3,
          'structure': 2,
          'missing': <String>['buildwhen', 'equatable'],
        },
      },
      <String, dynamic>{
        'id': 'seed-sm-2',
        'question':
            'When would you reach for a Cubit instead of a Bloc, and what do '
            'you give up by doing so?',
        'index': 2,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'Cubit when there are no meaningful event names. You lose the '
            'event log, so debugging has less to go on.',
        'score': <String, dynamic>{
          'correctness': 2,
          'depth': 3,
          'clarity': 3,
          'structure': 2,
          'missing': <String>['transformer', 'audit'],
        },
      },
    ],
  },
  <String, dynamic>{
    'id': 'seed-widget-lifecycle',
    'topic': 'widget-lifecycle',
    'completed_at': '2026-10-13T19:20:00.000Z',
    'turns': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'seed-wl-1',
        'question':
            'Why is it wrong to call an async API directly inside build(), '
            'and where should that call go instead?',
        'index': 1,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'build() can run many times per frame, so the call would fire '
            'repeatedly. It belongs in initState or a bloc event.',
        'score': <String, dynamic>{
          'correctness': 4,
          'depth': 3,
          'clarity': 3,
          'structure': 4,
          'missing': <String>['didchangedependencies'],
        },
      },
      <String, dynamic>{
        'id': 'seed-wl-2',
        'question':
            'What runs in didChangeDependencies that cannot run in '
            'initState, and why?',
        'index': 2,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'Anything reading an InheritedWidget, because the element is not '
            'yet wired to its ancestors during initState.',
        'score': <String, dynamic>{
          'correctness': 2,
          'depth': 3,
          'clarity': 3,
          'structure': 4,
          'missing': <String>['inherited', 'of(context)'],
        },
      },
    ],
  },
  <String, dynamic>{
    'id': 'seed-keys',
    'topic': 'keys',
    'completed_at': '2026-10-14T08:11:00.000Z',
    'turns': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'seed-keys-1',
        'question':
            'A reorderable list of stateful tiles keeps the wrong state on '
            'the wrong row after a drag. What is going on?',
        'index': 1,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer': 'The rows need keys.',
        'score': <String, dynamic>{
          'correctness': 3,
          'depth': 1,
          'clarity': 2,
          'structure': 2,
          'missing': <String>['element', 'runtimetype', 'valuekey'],
        },
      },
      <String, dynamic>{
        'id': 'seed-keys-2',
        'question':
            'You mentioned keys. What exactly does the element tree compare '
            'when it decides whether to reuse a widget?',
        'index': 1,
        'total': 2,
        'kind': 'followUp',
        'reason': 'depth',
        'answer': 'It compares the widget type and the key if there is one.',
        'score': <String, dynamic>{
          'correctness': 1,
          'depth': 3,
          'clarity': 2,
          'structure': 2,
          'missing': <String>['canupdate', 'position'],
        },
      },
    ],
  },
  <String, dynamic>{
    'id': 'seed-async-isolates',
    'topic': 'async-isolates',
    'completed_at': '2026-10-15T21:45:00.000Z',
    'turns': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'seed-ai-1',
        'question':
            'Parsing a large JSON payload janks the UI. Walk me through how '
            'you would move it off the main isolate.',
        'index': 1,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'Run the parse through compute(), which spawns an isolate and '
            'returns the decoded result.',
        'score': <String, dynamic>{
          'correctness': 4,
          'depth': 2,
          'clarity': 3,
          'structure': 3,
          'missing': <String>['sendport', 'transferable'],
        },
      },
      <String, dynamic>{
        'id': 'seed-ai-2',
        'question':
            'What can and cannot cross an isolate boundary, and why does '
            'that constraint exist?',
        'index': 2,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'Only primitives and simple structures. Isolates do not share '
            'memory, so everything is copied.',
        'score': <String, dynamic>{
          'correctness': 2,
          'depth': 2,
          'clarity': 3,
          'structure': 3,
          'missing': <String>['closure', 'copy cost'],
        },
      },
    ],
  },
  <String, dynamic>{
    'id': 'seed-performance',
    'topic': 'performance',
    'completed_at': '2026-10-16T17:02:00.000Z',
    'turns': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'seed-perf-1',
        'question':
            'A list scrolls at 40fps on a mid-range Android device. How do '
            'you find out why before changing any code?',
        'index': 1,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'Profile in release mode with the timeline, and check whether '
            'the cost sits in build, layout or raster.',
        'score': <String, dynamic>{
          'correctness': 5,
          'depth': 3,
          'clarity': 4,
          'structure': 4,
          'missing': <String>['repaintboundary'],
        },
      },
      <String, dynamic>{
        'id': 'seed-perf-2',
        'question':
            'When does const on a widget actually save work, and when is it '
            'just noise?',
        'index': 2,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'It helps when the subtree would otherwise rebuild, because the '
            'identical instance short-circuits the diff.',
        'score': <String, dynamic>{
          'correctness': 3,
          'depth': 3,
          'clarity': 2,
          'structure': 4,
          'missing': <String>['canupdate', 'identical'],
        },
      },
    ],
  },
  <String, dynamic>{
    'id': 'seed-navigation',
    'topic': 'navigation',
    'completed_at': '2026-10-17T20:30:00.000Z',
    'turns': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'seed-nav-1',
        'question':
            'Why pass an id rather than an object when navigating to a '
            'detail screen?',
        'index': 1,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'So deep links and refreshes work. The destination fetches what '
            'it needs rather than depending on the caller.',
        'score': <String, dynamic>{
          'correctness': 5,
          'depth': 4,
          'clarity': 3,
          'structure': 4,
          'missing': <String>['restoration'],
        },
      },
      <String, dynamic>{
        'id': 'seed-nav-2',
        'question':
            'What does a StatefulShellRoute buy you over swapping bodies in '
            'an IndexedStack yourself?',
        'index': 2,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'Each branch keeps its own navigator and stack, so a tab keeps '
            'its history and the URL stays truthful.',
        'score': <String, dynamic>{
          'correctness': 3,
          'depth': 4,
          'clarity': 3,
          'structure': 4,
          'missing': <String>['branch state'],
        },
      },
    ],
  },
  <String, dynamic>{
    'id': 'seed-testing',
    'topic': 'testing',
    'completed_at': '2026-10-18T09:15:00.000Z',
    'turns': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'seed-test-1',
        'question':
            'What do you assert in a bloc test that a widget test would not '
            'catch?',
        'index': 1,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'The exact emitted state sequence, including the loading state a '
            'widget test can easily pump straight past.',
        'score': <String, dynamic>{
          'correctness': 5,
          'depth': 4,
          'clarity': 4,
          'structure': 4,
          'missing': <String>['failure path'],
        },
      },
      <String, dynamic>{
        'id': 'seed-test-2',
        'question':
            'pumpAndSettle hangs in one of your tests. What are the usual '
            'causes?',
        'index': 2,
        'total': 2,
        'kind': 'initial',
        'reason': null,
        'answer':
            'A repeating animation or an indeterminate progress indicator '
            'that never settles, so the frame loop never drains.',
        'score': <String, dynamic>{
          'correctness': 3,
          'depth': 4,
          'clarity': 4,
          'structure': 4,
          'missing': <String>['pending timer'],
        },
      },
    ],
  },
];
