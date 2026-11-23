import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/theme/size_class.dart';
import '../../../../core/widgets/mettle/boxes.dart';
import '../../../../core/widgets/mettle/surface_card.dart';
import '../../../dashboard/presentation/widgets/brief_top_bar.dart';

Future<void> openPro(BuildContext context) async {
  await GoRouter.of(context).pushNamed<void>(AppRoutes.proName);
}

class ProPage extends StatelessWidget {
  const ProPage({super.key});

  static const contentMaxWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.text;
    final sizeClass = context.sizeClass;

    return Scaffold(
      backgroundColor: colors.bgPage,
      body: Column(
        children: [
          BriefTopBar(onBack: () => _leave(context)),
          Expanded(
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.proComingOverline,
                        style: TextStyle(
                          fontFamily: MettleText.mono,
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                          color: colors.accentText,
                        ),
                      ),
                      const SizedBox(height: MettleSpace.s4),
                      Text(
                        AppStrings.proComingTitle,
                        style: sizeClass.isCompact
                            ? styles.headline
                            : styles.display,
                      ),
                      const SizedBox(height: MettleSpace.s3),
                      Text(AppStrings.proComingBody, style: styles.bodyLarge),
                      SizedBox(height: context.sectionGap),
                      SurfaceCard(
                        padding: EdgeInsets.all(context.startCardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CardTitle(text: AppStrings.proComingWhat),
                            const SizedBox(height: MettleSpace.s4),
                            for (final perk in const [
                              AppStrings.proPerk1,
                              AppStrings.proPerk2,
                              AppStrings.proPerk3,
                              AppStrings.proPerk4,
                            ]) ...[
                              CheckItem(label: perk),
                              const SizedBox(height: MettleSpace.s3),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: MettleSpace.s5),
                      const InfoBox(
                        icon: Icons.schedule_rounded,
                        title: AppStrings.proComingFreeTitle,
                        body: AppStrings.proComingFreeBody,
                      ),
                      // SizedBox(height: context.sectionGap),
                      // Align(
                      //   alignment: Alignment.centerLeft,
                      //   child: PrimaryButton(
                      //     label: AppStrings.proComingBack,
                      //     trailingIcon: Icons.arrow_forward_rounded,
                      //     onPressed: () => _leave(context),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _leave(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    router.go(AppRoutes.dashboard);
  }
}
