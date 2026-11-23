import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';

typedef InteractiveBuilder = Widget Function(
  BuildContext context,
  bool hovered,
  bool pressed,
);

class FocusRing extends StatefulWidget {
  const FocusRing({
    required this.radius,
    required this.builder,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.selected,
    this.inGroup = false,
    this.hint,
    super.key,
  });

  final double radius;
  final InteractiveBuilder builder;
  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticLabel;
  final bool? selected;
  final bool inGroup;
  final String? hint;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      selected: widget.selected,
      inMutuallyExclusiveGroup: widget.inGroup ? true : null,
      label: widget.semanticLabel,
      hint: widget.hint,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: widget.enabled,
          mouseCursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onShowHoverHighlight: (value) => setState(() => _hovered = value),
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.enabled ? widget.onTap : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.builder(context, _hovered, _pressed),
                if (_focused)
                  Positioned(
                    left: -4,
                    top: -4,
                    right: -4,
                    bottom: -4,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.radius + 2,
                          ),
                          border: Border.all(
                            color: colors.accentText,
                            width: 2,
                          ),
                        ),
                      ),
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
