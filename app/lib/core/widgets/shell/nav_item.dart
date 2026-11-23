import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';

class NavItem extends StatefulWidget {
  const NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool locked;
  final Widget? trailing;

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final foreground = widget.locked
        ? colors.textTertiary
        : widget.selected
        ? colors.textPrimary
        : colors.textSecondary;

    final background = switch (true) {
      _ when widget.selected => colors.surfaceRaised,
      _ when _pressed => colors.surfaceRaised,
      _ when _hovered => colors.surfaceCard,
      _ => Colors.transparent,
    };

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: !widget.locked,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: MettleMotion.fast,
            curve: Curves.easeOut,
            constraints: const BoxConstraints(
              minHeight: MettleSpace.minTouchTarget,
            ),
            padding: const EdgeInsets.all(MettleSpace.s3),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(MettleSpace.rMd),
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: MettleSpace.iconNav, color: foreground),
                const SizedBox(width: MettleSpace.s3),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelLarge.copyWith(
                      fontWeight: widget.selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: foreground,
                    ),
                  ),
                ),
                ?widget.trailing,
                if (widget.locked)
                  Icon(
                    Icons.lock_outline_rounded,
                    size: MettleSpace.iconLockNav,
                    color: colors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
