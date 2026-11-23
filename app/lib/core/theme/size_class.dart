import 'package:flutter/material.dart';

import 'mettle_space.dart';

enum SizeClass {
  compact,
  medium,
  expanded;

  bool get isCompact => this == SizeClass.compact;
  bool get isExpanded => this == SizeClass.expanded;
  bool get hasSidebar => this == SizeClass.expanded;
  bool get hasBottomNav => this != SizeClass.expanded;
  bool get hasStickyCta => this == SizeClass.compact;
  bool get hoverEnabled => this != SizeClass.compact;
}

SizeClass sizeClassOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return SizeClass.compact;
  if (width < 1024) return SizeClass.medium;
  return SizeClass.expanded;
}

extension SizeClassX on BuildContext {
  SizeClass get sizeClass => sizeClassOf(this);

  EdgeInsets get pagePadding => switch (sizeClass) {
    SizeClass.compact => const EdgeInsets.fromLTRB(
      MettleSpace.s4,
      MettleSpace.s4,
      MettleSpace.s4,
      MettleSpace.s6,
    ),
    SizeClass.medium => const EdgeInsets.fromLTRB(
      MettleSpace.s6,
      MettleSpace.s6,
      MettleSpace.s6,
      MettleSpace.s8,
    ),
    SizeClass.expanded => const EdgeInsets.fromLTRB(
      MettleSpace.s10,
      MettleSpace.s10,
      MettleSpace.s10,
      MettleSpace.s16,
    ),
  };

  double get sectionGap =>
      sizeClass.isCompact ? MettleSpace.s4 : MettleSpace.s6;

  double get cardPadding =>
      sizeClass.isCompact ? MettleSpace.s4 : MettleSpace.s6;

  double get startCardPadding => switch (sizeClass) {
    SizeClass.compact => MettleSpace.s5,
    SizeClass.medium => MettleSpace.s6,
    SizeClass.expanded => MettleSpace.s7,
  };

  Duration motion(Duration value) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : value;
}

int columnsFor({
  required double width,
  required double tileMin,
  required int min,
  required int max,
  double gap = MettleSpace.s3,
}) {
  final count = ((width + gap) / (tileMin + gap)).floor();
  return count.clamp(min, max);
}
