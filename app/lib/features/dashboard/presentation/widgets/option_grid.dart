import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/option_tile.dart';
import '../../../../core/widgets/mettle/pills.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/interview_setup_cubit.dart';

class TileGrid extends StatelessWidget {
  const TileGrid({required this.columns, required this.tiles, super.key});

  final int columns;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var start = 0; start < tiles.length; start += columns) {
      final row = tiles.skip(start).take(columns).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < columns; index++) ...[
              if (index > 0) const SizedBox(width: MettleSpace.s3),
              Expanded(
                child: index < row.length ? row[index] : const SizedBox(),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const SizedBox(height: MettleSpace.s3),
          IntrinsicHeight(child: row),
        ],
      ],
    );
  }
}

class LevelGrid extends StatelessWidget {
  const LevelGrid({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  static const tileMin = 96.0;

  final Level selected;
  final ValueChanged<Level> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final perTile =
            (constraints.maxWidth - MettleSpace.s3 * 2) / Level.values.length;
        final columns = perTile >= tileMin ? 3 : 1;

        return TileGrid(
          columns: columns,
          tiles: [
            for (final level in Level.values)
              OptionTile(
                title: level.label,
                subtitle: level.years,
                selected: level == selected,
                onTap: () => onSelected(level),
              ),
          ],
        );
      },
    );
  }
}

class TopicGrid extends StatelessWidget {
  const TopicGrid({
    required this.topics,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  static const tileMin = 220.0;

  final List<TopicProgress> topics;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(
          width: constraints.maxWidth,
          tileMin: tileMin,
          min: 1,
          max: 4,
        );

        return TileGrid(
          columns: columns,
          tiles: [
            for (final topic in topics)
              OptionTile(
                title: topic.name,
                subtitle: topic.covers,
                selected: topic.id == selected,
                onTap: () => onSelected(topic.id),
                trailing: topic.status == TopicStatus.notTried
                    ? Text(
                        AppStrings.startNotTried,
                        style: context.text.caption,
                      )
                    : null,
              ),
          ],
        );
      },
    );
  }
}

class CountGrid extends StatelessWidget {
  const CountGrid({
    required this.selected,
    required this.onSelected,
    required this.onLocked,
    super.key,
  });

  static const badgeMinWidth = 110.0;

  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onLocked;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final perTile =
            (constraints.maxWidth - MettleSpace.s3 * 2) / questionCounts.length;
        final iconOnly = perTile < badgeMinWidth;

        return TileGrid(
          columns: 3,
          tiles: [
            for (final count in questionCounts)
              OptionTile(
                title: '$count',
                mono: true,
                subtitle: AppStrings.startMinutes(questionMinutes[count] ?? 0),
                selected: count == selected,
                locked: count == proQuestionCount,
                onTap: () =>
                    count == proQuestionCount ? onLocked() : onSelected(count),
                trailing: count == proQuestionCount
                    ? ProBadge(label: AppStrings.proBadge, iconOnly: iconOnly)
                    : null,
              ),
          ],
        );
      },
    );
  }
}
