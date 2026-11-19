import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import 'credit_meter.dart';

class FreePlanCard extends StatelessWidget {
  const FreePlanCard({
    required this.remaining,
    required this.total,
    this.onSeePlans,
    this.onUpgrade,
    super.key,
  });

  final int remaining;
  final int total;
  final VoidCallback? onSeePlans;
  final VoidCallback? onUpgrade;

  bool get _exhausted => remaining == 0;
  bool get _lastOne => remaining == 1;
  bool get _untouched => remaining == total;

  String get _title => _lastOne
      ? AppStrings.planLastFree
      : AppStrings.planRemaining(remaining, total);

  String? get _note {
    if (_untouched) return AppStrings.planFirstRunNote;
    if (_lastOne) return AppStrings.planLastFreeNote;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final note = _note;

    return Container(
      padding: const EdgeInsets.all(MettleSpace.s4),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(MettleSpace.rMd),
        border: Border.all(
          color: _exhausted ? colors.accentBorder40 : colors.borderDefault,
          width: MettleSpace.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.planOverline, style: text.overline),
              ),
              if (!_exhausted && onSeePlans != null)
                _PlanLink(label: AppStrings.planSeePlans, onTap: onSeePlans!),
            ],
          ),
          const SizedBox(height: MettleSpace.s3),
          Text(_title, style: text.labelLarge),
          const SizedBox(height: MettleSpace.s3),
          CreditMeter(remaining: remaining, total: total),
          if (note != null) ...[
            const SizedBox(height: MettleSpace.s3),
            Text(note, style: text.caption),
          ],
          if (_exhausted && onUpgrade != null) ...[
            const SizedBox(height: MettleSpace.s3),
            SizedBox(
              width: double.infinity,
              height: MettleSpace.minTouchTarget,
              child: _UpgradeButton(onTap: onUpgrade!),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanLink extends StatefulWidget {
  const _PlanLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_PlanLink> createState() => _PlanLinkState();
}

class _PlanLinkState extends State<_PlanLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Semantics(
          button: true,
          child: Text(
            widget.label,
            style: context.text.link.copyWith(
              color: _hovered ? colors.accentTextHover : colors.accentText,
              decoration: _hovered ? TextDecoration.underline : null,
              decorationColor: colors.accentTextHover,
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.accent,
      borderRadius: BorderRadius.circular(MettleSpace.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MettleSpace.rMd),
        splashFactory: NoSplash.splashFactory,
        child: Center(
          child: Text(AppStrings.planUpgrade, style: context.text.buttonLarge),
        ),
      ),
    );
  }
}
