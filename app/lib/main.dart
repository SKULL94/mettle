import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MettleApp());
}

class MettleApp extends StatefulWidget {
  const MettleApp({super.key});

  @override
  State<MettleApp> createState() => _MettleAppState();
}

class _MettleAppState extends State<MettleApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),

      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
