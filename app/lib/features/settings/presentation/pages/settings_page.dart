import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/window_size.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_dashboard.dart';
import '../widgets/settings_sections.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWideWindow;

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(title: const Text(AppStrings.settingsTitle)),
      body: SafeArea(
        child: isWide ? const SettingsDashboard() : const _SettingsList(),
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.md,
        AppDimens.md,
        AppDimens.md,
        AppDimens.xl,
      ),
      children: const [
        AppearanceSection(),
        SizedBox(height: AppDimens.xl),
        DataSection(),
        SizedBox(height: AppDimens.xl),
        AboutSection(),
      ],
    );
  }
}
