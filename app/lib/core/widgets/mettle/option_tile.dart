import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import '../../theme/size_class.dart';
import 'focus_ring.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.locked = false,
    this.mono = false,
    this.statusSlot,
    this.hint,
    super.key,
  });

  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool selected;
  final bool locked;
  final bool mono;
  final Widget? statusSlot;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final compact = context.sizeClass.isCompact;
    final caption = subtitle;

    return FocusRing(
      radius: MettleSpace.rMd,
      onTap: onTap,
      selected: locked ? false : selected,
      inGroup: true,
      semanticLabel: title,
      hint: locked ? 'Pro only' : hint,
      builder: (context, hovered, pressed) {
        final fill = switch (true) {
          _ when selected && !locked => colors.accentTint12,
          _ when pressed => colors.surfacePressed,
          _ => colors.surfaceRaised,
        };

        final border = switch (true) {
          _ when selected && !locked => colors.accent,
          _ when hovered => colors.borderStrong,
          _ => colors.borderDefault,
        };

        return AnimatedContainer(
          duration: context.motion(MettleMotion.base),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(
            minHeight: MettleSpace.minTouchTarget,
          ),
          padding: EdgeInsets.symmetric(
            vertical: MettleSpace.s3,
            horizontal: compact ? MettleSpace.s3 : MettleSpace.s4,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(MettleSpace.rMd),
            border: Border.all(color: border, width: MettleSpace.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: mono
                          ? styles.monoLarge
                          : styles.labelLarge.copyWith(
                              color: locked
                                  ? colors.textSecondary
                                  : colors.textPrimary,
                            ),
                    ),
                    if (statusSlot != null) ...[
                      const SizedBox(height: MettleSpace.s2),
                      statusSlot!,
                    ],
                    if (caption != null) ...[
                      const SizedBox(height: MettleSpace.s1),
                      Text(
                        caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: styles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: MettleSpace.s2),
                trailing!,
              ],
            ],
          ),
        );
      },
    );
  }
}
