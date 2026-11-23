import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';

class MettleBrand extends StatelessWidget {
  const MettleBrand({this.compact = false, this.onTap, super.key});

  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final size = compact ? 28.0 : 32.0;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(MettleSpace.rSm),
          ),
          child: Text(
            AppStrings.brandMark,
            style: TextStyle(
              fontFamily: MettleText.sans,
              fontSize: 16,
              height: 1,
              fontWeight: FontWeight.w800,
              color: colors.onAccent,
            ),
          ),
        ),
        SizedBox(width: compact ? MettleSpace.s2 : MettleSpace.s3),
        if (compact)
          Flexible(
            child: Text(
              AppStrings.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: MettleText.sans,
                fontSize: 17,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          )
        else
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MettleText.sans,
                    fontSize: 18,
                    height: 22 / 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  AppStrings.shellBrandTagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.caption,
                ),
              ],
            ),
          ),
      ],
    );

    if (onTap == null) return row;

    return Semantics(
      button: true,
      label: AppStrings.appName,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MettleSpace.rSm),
        child: row,
      ),
    );
  }
}
