import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Route boundary. Gains its bloc and real content in the next Phase 1 slice;
/// for now it exists so the shell and routing are verifiable end to end.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Center(
        child: Text(
          AppStrings.navHome,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
