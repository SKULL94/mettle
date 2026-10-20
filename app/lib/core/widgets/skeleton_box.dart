import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height = AppDimens.md,
    this.radius = AppDimens.sm,
    super.key,
  });

  const SkeletonBox.text({double width = 120, Key? key})
    : this(width: width, height: 12, radius: AppDimens.xs, key: key);

  const SkeletonBox.circle({double size = AppDimens.scoreRingSize, Key? key})
    : this(width: size, height: size, radius: AppDimens.radiusPill, key: key);

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
