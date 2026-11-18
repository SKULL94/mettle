import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_frame.dart';
import 'settings_sections.dart';

class SettingsDashboard extends StatefulWidget {
  const SettingsDashboard({super.key});

  @override
  State<SettingsDashboard> createState() => _SettingsDashboardState();
}

typedef SettingsPane = ({String title, Widget Function(Key key) build});

class _SettingsDashboardState extends State<SettingsDashboard> {
  static final _panes = <SettingsPane>[
    (title: AppStrings.appearance, build: (key) => AppearanceSection(key: key)),
    (title: AppStrings.data, build: (key) => DataSection(key: key)),
    (title: AppStrings.about, build: (key) => AboutSection(key: key)),
  ];

  late final _keys = List.generate(_panes.length, (_) => GlobalKey());
  int _active = 0;

  Future<void> _jumpTo(int index) async {
    setState(() => _active = index);

    final target = _keys[index].currentContext;
    if (target == null) return;

    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimens.contentMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.gutter,
                AppDimens.lg,
                AppDimens.gutter,
                0,
              ),
              child: PageHeader(
                eyebrow: AppStrings.settingsIndex,
                title: AppStrings.settingsTitle,
                subtitle: AppStrings.settingsSubtitle,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimens.gutter),
                    child: _Index(
                      titles: [for (final pane in _panes) pane.title],
                      active: _active,
                      onSelected: _jumpTo,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paneGap),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                        right: AppDimens.gutter,
                        bottom: AppDimens.xxl,
                      ),
                      children: [
                        for (final (index, pane) in _panes.indexed) ...[
                          if (index > 0) const SizedBox(height: AppDimens.xl),
                          pane.build(_keys[index]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Index extends StatelessWidget {
  const _Index({
    required this.titles,
    required this.active,
    required this.onSelected,
  });

  final List<String> titles;
  final int active;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimens.indexWidth,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, title) in titles.indexed)
                _IndexItem(
                  position: index + 1,
                  title: title,
                  selected: index == active,
                  onTap: () => onSelected(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndexItem extends StatelessWidget {
  const _IndexItem({
    required this.position,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final int position;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: selected
          ? theme.colorScheme.surfaceContainerHigh
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        child: Semantics(
          selected: selected,
          button: true,
          child: Container(
            height: AppDimens.minTouchTarget,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
                Text(
                  position.toString().padLeft(2, '0'),
                  style: AppTheme.code(context).copyWith(
                    fontSize: 12,
                    color: theme.textTheme.labelSmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
