import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/mettle_snack_bar.dart';
import '../../../../core/widgets/selectable_tile.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../cubit/settings_cubit.dart';
import 'settings_section.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

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

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: AppStrings.data,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SettingsRow(
              title: AppStrings.privacy,
              body: AppStrings.privacyBody,
              trailing: Icon(
                Icons.open_in_new_rounded,
                size: AppDimens.iconMd,
                color: theme.textTheme.labelSmall?.color,
              ),
              onTap: () => _openPrivacyPolicy(context),
            ),
            const Divider(height: AppDimens.hairline),
            SettingsRow(
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
            const Divider(height: AppDimens.hairline),
            SettingsRow(
              title: AppStrings.deleteAccount,
              body: AppStrings.deleteAccountBody,
              titleColor: theme.colorScheme.error,
              trailing: Icon(
                Icons.person_remove_outlined,
                size: AppDimens.iconMd,
                color: theme.colorScheme.error,
              ),
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openPrivacyPolicy(BuildContext context) async {
  final opened = await launchUrl(
    Uri.parse(AppStrings.privacyUrl),
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );

  if (opened || !context.mounted) return;

  await Clipboard.setData(const ClipboardData(text: AppStrings.privacyUrl));
  if (!context.mounted) return;
  showMettleSnackBar(context, AppStrings.privacyFallback);
}

Future<void> _confirmDeleteAccount(BuildContext context) async {
  final cubit = context.read<SettingsCubit>();

  final confirmed = await showConfirmDialog(
    context,
    title: AppStrings.deleteAccount,
    message: AppStrings.deleteAccountPrompt,
    confirmLabel: AppStrings.deleteAccountConfirm,
    destructive: true,
  );

  if (!confirmed) return;

  final deleted = await cubit.deleteAccount();
  if (!context.mounted) return;

  if (!deleted) {
    showMettleSnackBar(context, AppStrings.deleteAccountError);
    return;
  }

  showMettleSnackBar(context, AppStrings.deleteAccountDone);
  context.go(AppRoutes.signIn);
}

Future<void> _confirmClear(BuildContext context) async {
  final cubit = context.read<SettingsCubit>();

  final confirmed = await showConfirmDialog(
    context,
    title: AppStrings.clearData,
    message: AppStrings.clearDataPrompt,
    confirmLabel: AppStrings.clearDataConfirm,
    destructive: true,
  );

  if (!confirmed) return;

  final cleared = await cubit.clearSessions();
  if (!context.mounted) return;

  showMettleSnackBar(
    context,
    cleared ? AppStrings.clearDataDone : AppStrings.cacheError,
  );
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: AppStrings.about,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SettingsRow(
              title: AppStrings.appName,
              body: AppStrings.appTagline,
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
