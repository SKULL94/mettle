import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Terminal screen of a session. Same feature as Interview: one bloc per
/// feature, not per screen.
class ScorecardPage extends StatelessWidget {
  const ScorecardPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.scorecard)),
      body: Center(
        child: Text(sessionId, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
