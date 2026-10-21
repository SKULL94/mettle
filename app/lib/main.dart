import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/app_theme_mode.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await sl<SettingsCubit>().load();

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
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, AppThemeMode>(
        builder: (context, mode) => MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: switch (mode) {
            AppThemeMode.system => ThemeMode.system,
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
          },
          routerConfig: _router,
        ),
      ),
    );
  }
}
