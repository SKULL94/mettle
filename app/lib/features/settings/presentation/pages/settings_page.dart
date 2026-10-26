import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/selectable_tile.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_section.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.md,
            AppDimens.md,
            AppDimens.md,
            AppDimens.xl,
          ),
          children: const [
            _Appearance(),
            SizedBox(height: AppDimens.xl),
            _Mode(),
            SizedBox(height: AppDimens.xl),
            _Data(),
            SizedBox(height: AppDimens.xl),
            _About(),
          ],
        ),
      ),
    );
  }
}

class _Appearance extends StatelessWidget {
  const _Appearance();

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: AppStrings.appearance,
      child: BlocBuilder<SettingsCubit, AppThemeMode>(
        builder: (context, selected) => Row(
          children: [
            for (final mode in AppThemeMode.values) ...[
              if (mode != AppThemeMode.values.first)
                const SizedBox(width: AppDimens.sm),
              Expanded(
                child: _ThemeTile(
                  mode: mode,
                  selected: mode == selected,
                  onTap: () =>
                      context.read<SettingsCubit>().selectThemeMode(mode),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (mode) {
      AppThemeMode.system => AppStrings.themeSystem,
      AppThemeMode.light => AppStrings.themeLight,
      AppThemeMode.dark => AppStrings.themeDark,
    };

    return SelectableTile(
      selected: selected,
      onTap: onTap,
      semanticLabel: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (mode) {
              AppThemeMode.system => Icons.brightness_auto_rounded,
              AppThemeMode.light => Icons.light_mode_rounded,
              AppThemeMode.dark => Icons.dark_mode_rounded,
            },
            size: AppDimens.iconMd,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Mode extends StatelessWidget {
  const _Mode();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const isDemo = !ApiConstants.isBackendConfigured;

    return SettingsSection(
      title: AppStrings.mode,
      child: Card(
        child: SettingsRow(
          leading: StatusDot(color: theme.colorScheme.primary),
          title: isDemo ? AppStrings.demoMode : AppStrings.liveModeTitle,
          body: isDemo ? AppStrings.demoModeBody : AppStrings.liveModeBody,
        ),
      ),
    );
  }
}

class _Data extends StatelessWidget {
  const _Data();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: AppStrings.data,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SettingsRow(
          title: AppStrings.clearData,
          body: AppStrings.clearDataBody,
          titleColor: theme.colorScheme.error,
          trailing: Icon(
            Icons.delete_outline_rounded,
            size: AppDimens.iconMd,
            color: theme.colorScheme.error,
          ),
          onTap: () => _confirmClear(context),
        ),
      ),
    );
  }
}

Future<void> _confirmClear(BuildContext context) async {
  final cubit = context.read<SettingsCubit>();
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.clearData),
      content: const Text(AppStrings.clearDataPrompt),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text(AppStrings.clearDataConfirm),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  final cleared = await cubit.clearSessions();
  messenger.showSnackBar(
    SnackBar(
      content: Text(cleared ? AppStrings.clearDataDone : AppStrings.cacheError),
    ),
  );
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: AppStrings.about,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SettingsRow(
              title: AppStrings.appName,
              body: AppStrings.appTagline,
              trailing: Text(
                AppStrings.appVersion,
                style: theme.textTheme.labelSmall,
              ),
            ),
            const Divider(height: AppDimens.hairline),
            SettingsRow(
              title: AppStrings.repository,
              body: AppStrings.repositoryUrl,
              trailing: Icon(
                Icons.copy_rounded,
                size: AppDimens.iconMd,
                color: theme.textTheme.labelSmall?.color,
              ),
              onTap: () => _copyRepositoryUrl(context),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _copyRepositoryUrl(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);

  await Clipboard.setData(const ClipboardData(text: AppStrings.repositoryUrl));
  messenger.showSnackBar(
    const SnackBar(content: Text(AppStrings.copiedToClipboard)),
  );
}
