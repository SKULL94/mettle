import 'package:flutter/material.dart';

import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import '../../theme/size_class.dart';
import 'focus_ring.dart';

enum ButtonSize { large, medium }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.large,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool fullWidth;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final enabled = onPressed != null && !busy;
    final height = size == ButtonSize.large ? 48.0 : 44.0;
    final padding = size == ButtonSize.large ? MettleSpace.s6 : MettleSpace.s4;

    return FocusRing(
      radius: MettleSpace.rMd,
      enabled: enabled,
      onTap: onPressed,
      semanticLabel: label,
      builder: (context, hovered, pressed) {
        final fill = switch (true) {
          _ when !enabled => colors.surfaceDisabled,
          _ when pressed => colors.accentPressed,
          _ when hovered => colors.accentHover,
          _ => colors.accent,
        };

        return AnimatedContainer(
          duration: context.motion(MettleMotion.fast),
          curve: Curves.easeOut,
          height: height,
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(MettleSpace.rMd),
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: busy
                ? [
                    SizedBox(
                      width: MettleSpace.iconNav,
                      height: MettleSpace.iconNav,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onAccent,
                      ),
                    ),
                  ]
                : [
                    if (leadingIcon != null && enabled) ...[
                      Icon(
                        leadingIcon,
                        size: MettleSpace.iconCheck,
                        color: colors.onAccent,
                      ),
                      const SizedBox(width: MettleSpace.s2),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: enabled
                            ? styles.buttonLarge
                            : styles.buttonLarge.copyWith(
                                color: colors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                      ),
                    ),
                    if (trailingIcon != null && enabled) ...[
                      const SizedBox(width: MettleSpace.s2),
                      Icon(
                        trailingIcon,
                        size: MettleSpace.iconNav,
                        color: colors.onAccent,
                      ),
                    ],
                  ],
          ),
        );
      },
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.large,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final height = size == ButtonSize.large ? 48.0 : 44.0;
    final padding = size == ButtonSize.large ? MettleSpace.s5 : MettleSpace.s4;

    return FocusRing(
      radius: MettleSpace.rMd,
      enabled: enabled,
      onTap: onPressed,
      semanticLabel: label,
      builder: (context, hovered, pressed) {
        final fill = switch (true) {
          _ when pressed => colors.surfacePressed,
          _ when hovered => colors.surfaceRaised,
          _ => Colors.transparent,
        };

        return AnimatedContainer(
          duration: context.motion(MettleMotion.fast),
          curve: Curves.easeOut,
          height: height,
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: padding),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(MettleSpace.rMd),
            border: Border.all(
              color: colors.borderDefault,
              width: MettleSpace.border,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: MettleText.sans,
              fontSize: 15,
              height: 20 / 15,
              fontWeight: FontWeight.w600,
              color: enabled ? colors.textPrimary : colors.textTertiary,
            ),
          ),
        );
      },
    );
  }
}

class SmallButton extends StatelessWidget {
  const SmallButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final height = context.sizeClass.isCompact ? 44.0 : 40.0;

    return FocusRing(
      radius: MettleSpace.rSm,
      enabled: enabled,
      onTap: onPressed,
      semanticLabel: label,
      builder: (context, hovered, pressed) {
        return AnimatedContainer(
          duration: context.motion(MettleMotion.fast),
          curve: Curves.easeOut,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: MettleSpace.s4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pressed ? colors.surfacePressed : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(MettleSpace.rSm),
            border: Border.all(
              color: hovered ? colors.borderStrong : colors.borderDefault,
              width: MettleSpace.border,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.buttonMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: enabled ? colors.textPrimary : colors.textTertiary,
            ),
          ),
        );
      },
    );
  }
}

class TextLink extends StatelessWidget {
  const TextLink({
    required this.label,
    required this.onTap,
    this.large = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final compact = context.sizeClass.isCompact;

    return FocusRing(
      radius: MettleSpace.rSm,
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hovered, pressed) {
        final text = Text(
          label,
          style: TextStyle(
            fontFamily: MettleText.sans,
            fontSize: large ? 14 : 13,
            height: large ? 20 / 14 : 18 / 13,
            fontWeight: FontWeight.w600,
            color: hovered ? colors.accentTextHover : colors.accentText,
            decoration: hovered ? TextDecoration.underline : null,
            decorationColor: colors.accentTextHover,
          ),
        );

        if (!compact) return text;

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: MettleSpace.minTouchTarget,
          ),
          child: Center(widthFactor: 1, child: text),
        );
      },
    );
  }
}
