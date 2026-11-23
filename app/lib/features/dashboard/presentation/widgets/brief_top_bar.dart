import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/shell/mettle_brand.dart';

class BriefTopBar extends StatelessWidget {
  const BriefTopBar({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizeClass = context.sizeClass;
    final compact = sizeClass.isCompact;

    return Container(
      height: compact ? MettleSpace.appBarCompact : MettleSpace.appBarMedium,
      padding: EdgeInsets.symmetric(
        horizontal: switch (sizeClass) {
          SizeClass.compact => MettleSpace.s4,
          SizeClass.medium => MettleSpace.s6,
          SizeClass.expanded => MettleSpace.s10,
        },
      ),
      decoration: BoxDecoration(
        color: colors.bgPage,
        border: Border(
          bottom: BorderSide(
            color: colors.borderSubtle,
            width: MettleSpace.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: MettleBrand(compact: compact)),
          const SizedBox(width: MettleSpace.s3),
          if (compact)
            IconButton(
              onPressed: onBack,
              tooltip: AppStrings.briefBack,
              iconSize: 22,
              color: colors.textSecondary,
              icon: const Icon(Icons.close_rounded),
            )
          else
            _BackButton(onTap: onBack),
        ],
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: MettleSpace.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              AppStrings.briefBack,
              style: context.text.buttonMedium.copyWith(
                color: _hovered ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
