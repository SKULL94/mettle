import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// M2 surface — theme, API base URL, demo-mode toggle, clear data.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navSettings)),
      body: Center(
        child: Text(
          AppStrings.navSettings,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
