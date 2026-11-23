import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

enum WindowSize {
  compact,
  medium,
  expanded;

  bool get isCompact => this == WindowSize.compact;
  bool get isWide => this != WindowSize.compact;
  bool get isExpanded => this == WindowSize.expanded;
}

extension WindowSizeX on BuildContext {
  WindowSize get windowSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width < AppDimens.breakpointWide) return WindowSize.compact;
    if (width < AppDimens.breakpointUltraWide) return WindowSize.medium;
    return WindowSize.expanded;
  }

  bool get isWideWindow => windowSize.isWide;
}
