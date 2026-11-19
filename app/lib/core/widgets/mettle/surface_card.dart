import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import '../../theme/size_class.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding,
    this.highlight = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(MettleSpace.rLg),
        border: Border.all(
          color: highlight ? colors.accentBorder40 : colors.borderDefault,
          width: MettleSpace.border,
        ),
        gradient: highlight
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.accent.withValues(alpha: 0.10),
                  colors.accent.withValues(alpha: 0.02),
                ],
              )
            : null,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(context.cardPadding),
        child: child,
      ),
    );
  }
}

class CardTitle extends StatelessWidget {
  const CardTitle({required this.text, this.large = false, super.key});

  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final styles = context.text;

    return Semantics(
      header: true,
      child: Text(text, style: large ? styles.titleLarge : styles.cardTitle),
    );
  }
}
