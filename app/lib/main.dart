import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  // No async work here on purpose: bootstrap belongs to the splash route, which
  // can show the wordmark while it runs instead of holding a blank frame.
  runApp(const MettleApp());
}

class MettleApp extends StatefulWidget {
  const MettleApp({super.key});

  @override
  State<MettleApp> createState() => _MettleAppState();
}

class _MettleAppState extends State<MettleApp> {
  // Built once and held: rebuilding a GoRouter throws away navigation state.
  // This is the acceptable use of State in the app — a local controller, not
  // feature state.
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Follows the OS until Settings lands in M2 and can store a preference.
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
