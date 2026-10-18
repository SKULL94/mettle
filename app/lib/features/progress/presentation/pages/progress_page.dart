import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// M2 surface. Present now only so the third shell branch is navigable.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navProgress)),
      body: Center(
        child: Text(
          AppStrings.navProgress,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
