import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// The core Phase 1 screen. Takes only the session id — the bloc fetches the
/// rest, which keeps deep links and browser refresh working.
class InterviewPage extends StatelessWidget {
  const InterviewPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Center(
        child: Text(sessionId, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
