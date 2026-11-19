import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import '../../theme/size_class.dart';
import 'focus_ring.dart';

@immutable
final class SegmentedOption {
  const SegmentedOption({required this.label, this.badge});

  final String label;
  final String? badge;
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  static const badgeMinWidth = 200.0;

  final List<SegmentedOption> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth =
            (constraints.maxWidth - MettleSpace.s2 - MettleSpace.s1 * 2) /
            options.length;

        return Container(
          padding: const EdgeInsets.all(MettleSpace.s1),
          decoration: BoxDecoration(
            color: colors.bgSidebar,
            borderRadius: BorderRadius.circular(MettleSpace.rMd),
            border: Border.all(
              color: colors.borderSubtle,
              width: MettleSpace.border,
            ),
          ),
          child: Row(
            children: [
              for (final (index, option) in options.indexed) ...[
                if (index > 0) const SizedBox(width: MettleSpace.s2),
                Expanded(
                  child: _Tab(
                    option: option,
                    selected: index == selected,
                    showBadge: tabWidth >= badgeMinWidth,
                    onTap: () => onSelected(index),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.option,
    required this.selected,
    required this.showBadge,
    required this.onTap,
  });

  final SegmentedOption option;
  final bool selected;
  final bool showBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badge = option.badge;

    return FocusRing(
      radius: MettleSpace.rSm,
      onTap: onTap,
      selected: selected,
      inGroup: true,
      semanticLabel: option.label,
      builder: (context, hovered, pressed) {
        return AnimatedContainer(
          duration: context.motion(MettleMotion.base),
          curve: Curves.easeOutCubic,
          height: MettleSpace.minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.surfaceRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(MettleSpace.rSm),
            border: selected
                ? Border.all(
                    color: colors.borderStrong,
                    width: MettleSpace.border,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.buttonMedium.copyWith(
                    color: selected || hovered
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                ),
              ),
              if (badge != null && showBadge) ...[
                const SizedBox(width: MettleSpace.s2),
                _InlineBadge(label: badge),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: MettleSpace.s2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(MettleSpace.rFull),
      ),
      child: Text(label.toUpperCase(), style: context.text.badge),
    );
  }
}
