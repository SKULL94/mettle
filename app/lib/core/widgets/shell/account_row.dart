import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';

enum AccountAction { profile, billing, signOut }

class AccountRow extends StatelessWidget {
  const AccountRow({
    required this.name,
    required this.email,
    required this.onSelected,
    super.key,
  });

  final String name;
  final String email;
  final ValueChanged<AccountAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MettleSpace.s1),
      child: Row(
        children: [
          AccountAvatar(name: name),
          const SizedBox(width: MettleSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium,
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.caption,
                ),
              ],
            ),
          ),
          AccountMenuButton(onSelected: onSelected),
        ],
      ),
    );
  }
}

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({required this.name, this.size = 36, super.key});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.avatarBg, shape: BoxShape.circle),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontFamily: MettleText.sans,
          fontSize: 13,
          height: 1,
          fontWeight: FontWeight.w700,
          color: colors.accentTextHover,
        ),
      ),
    );
  }
}

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton({required this.onSelected, super.key});

  final ValueChanged<AccountAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<AccountAction>(
      onSelected: onSelected,
      tooltip: AppStrings.shellAccountMenu,
      position: PopupMenuPosition.under,
      color: colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MettleSpace.rMd),
        side: BorderSide(
          color: colors.borderDefault,
          width: MettleSpace.border,
        ),
      ),
      itemBuilder: (context) => [
        _item(context, AccountAction.profile, AppStrings.shellProfile),
        _item(context, AccountAction.billing, AppStrings.shellPlanBilling),
        _item(context, AccountAction.signOut, AppStrings.shellSignOut),
      ],
      child: SizedBox(
        width: MettleSpace.minTouchTarget,
        height: MettleSpace.minTouchTarget,
        child: Icon(
          Icons.more_vert_rounded,
          size: MettleSpace.iconNav,
          color: colors.textTertiary,
        ),
      ),
    );
  }

  PopupMenuItem<AccountAction> _item(
    BuildContext context,
    AccountAction value,
    String label,
  ) {
    return PopupMenuItem<AccountAction>(
      value: value,
      child: Text(label, style: context.text.bodyMedium),
    );
  }
}
