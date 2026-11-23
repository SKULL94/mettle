import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_strings.dart';

class MettleMark extends StatelessWidget {
  const MettleMark({this.size = 96.0, super.key});

  static const asset = 'assets/brand/mettle_mark.svg';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.appName,
      image: true,
      child: SvgPicture.asset(asset, width: size, height: size),
    );
  }
}

class MettleWordmark extends StatelessWidget {
  const MettleWordmark({this.style, super.key});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.appName,
      style: style ?? Theme.of(context).textTheme.displaySmall,
    );
  }
}
