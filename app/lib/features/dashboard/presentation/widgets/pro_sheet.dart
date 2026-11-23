import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/mettle_colors.dart';
import '../../../../core/theme/mettle_space.dart';
import '../../../../core/theme/mettle_text.dart';
import '../../../../core/widgets/mettle/buttons.dart';
import '../../../pro/presentation/pages/pro_page.dart';

Future<void> showProSheet(BuildContext context) {
  final colors = context.colors;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.bgSidebar,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MettleSpace.s4,
          0,
          MettleSpace.s4,
          MettleSpace.s4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.proSheetTitle, style: sheetContext.text.cardTitle),
            const SizedBox(height: MettleSpace.s2),
            Text(AppStrings.proSheetBody, style: sheetContext.text.bodyMedium),
            const SizedBox(height: MettleSpace.s5),
            PrimaryButton(
              label: AppStrings.proSheetSeePlans,
              fullWidth: true,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                openPro(context);
              },
            ),
            const SizedBox(height: MettleSpace.s3),
            SecondaryButton(
              label: AppStrings.proSheetNotNow,
              fullWidth: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
