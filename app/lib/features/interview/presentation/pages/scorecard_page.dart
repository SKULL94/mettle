import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

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
