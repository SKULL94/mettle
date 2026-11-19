import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/mettle_colors.dart';
import '../../theme/mettle_space.dart';
import '../../theme/mettle_text.dart';
import '../../theme/size_class.dart';
import 'account_row.dart';
import 'credit_chip.dart';
import 'free_plan_card.dart';
import 'mettle_brand.dart';
import 'nav_item.dart';
import 'shell_destination.dart';

@immutable
final class ShellState {
  const ShellState({
    required this.name,
    required this.email,
    required this.freeRemaining,
    required this.freeTotal,
    required this.completedInterviews,
  });

  final String name;
  final String email;
  final int freeRemaining;
  final int freeTotal;
  final int completedInterviews;

  bool get progressLocked => completedInterviews == 0;
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.tab,
    required this.state,
    required this.body,
    required this.onSelect,
    required this.onAccount,
    this.onSeePlans,
    this.onUpgrade,
    this.bottomBar,
    super.key,
  });

  final ShellTab tab;
  final ShellState state;
  final Widget body;
  final ValueChanged<ShellDestination> onSelect;
  final ValueChanged<AccountAction> onAccount;
  final VoidCallback? onSeePlans;
  final VoidCallback? onUpgrade;
  final Widget? bottomBar;

  void _select(BuildContext context, ShellDestination destination) {
    if (destination.tab == ShellTab.progress && state.progressLocked) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text(AppStrings.shellProgressLocked)),
        );
      return;
    }
    onSelect(destination);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (context.sizeClass.hasSidebar) {
      return Scaffold(
        backgroundColor: colors.bgPage,
        body: Row(
          children: [
            _Sidebar(
              tab: tab,
              state: state,
              onSelect: (d) => _select(context, d),
              onAccount: onAccount,
              onSeePlans: onSeePlans,
              onUpgrade: onUpgrade,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: _CompactBar(state: state, onAccount: onAccount),
      body: body,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?bottomBar,
          _BottomNav(
            tab: tab,
            locked: state.progressLocked,
            onSelect: (d) => _select(context, d),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.tab,
    required this.state,
    required this.onSelect,
    required this.onAccount,
    this.onSeePlans,
    this.onUpgrade,
  });

  final ShellTab tab;
  final ShellState state;
  final ValueChanged<ShellDestination> onSelect;
  final ValueChanged<AccountAction> onAccount;
  final VoidCallback? onSeePlans;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: MettleSpace.sidebarWidth,
      decoration: BoxDecoration(
        color: colors.bgSidebar,
        border: Border(
          right: BorderSide(
            color: colors.borderSubtle,
            width: MettleSpace.border,
          ),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MettleSpace.s4,
                    vertical: MettleSpace.s6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MettleSpace.s2,
                        ),
                        child: MettleBrand(),
                      ),
                      const SizedBox(height: MettleSpace.s7),
                      for (final destination in shellDestinations) ...[
                        if (destination != shellDestinations.first)
                          const SizedBox(height: MettleSpace.s1),
                        NavItem(
                          icon: destination.icon,
                          label: destination.label,
                          selected: destination.tab == tab,
                          locked:
                              destination.tab == ShellTab.progress &&
                              state.progressLocked,
                          trailing: destination.tab == ShellTab.history
                              ? Text(
                                  '${state.completedInterviews}',
                                  style: context.text.monoSmall,
                                )
                              : null,
                          onTap: () => onSelect(destination),
                        ),
                      ],
                      const SizedBox(height: MettleSpace.s7),
                      const Spacer(),
                      FreePlanCard(
                        remaining: state.freeRemaining,
                        total: state.freeTotal,
                        onSeePlans: onSeePlans,
                        onUpgrade: onUpgrade,
                      ),
                      const SizedBox(height: MettleSpace.s7),
                      AccountRow(
                        name: state.name,
                        email: state.email,
                        onSelected: onAccount,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactBar extends StatelessWidget implements PreferredSizeWidget {
  const _CompactBar({required this.state, required this.onAccount});

  final ShellState state;
  final ValueChanged<AccountAction> onAccount;

  @override
  Size get preferredSize => const Size.fromHeight(MettleSpace.appBarMedium);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final compact = context.sizeClass.isCompact;
    final height = compact
        ? MettleSpace.appBarCompact
        : MettleSpace.appBarMedium;

    return SafeArea(
      bottom: false,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? MettleSpace.s4 : MettleSpace.s6,
        ),
        decoration: BoxDecoration(
          color: colors.bgSidebar,
          border: Border(
            bottom: BorderSide(
              color: colors.borderSubtle,
              width: MettleSpace.border,
            ),
          ),
        ),
        child: Row(
          children: [
            const Expanded(child: MettleBrand(compact: true)),
            const SizedBox(width: MettleSpace.s2),
            CreditChip(
              remaining: state.freeRemaining,
              total: state.freeTotal,
              onTap: () => _showPlanSheet(context, state),
            ),
            const SizedBox(width: MettleSpace.s2),
            AccountMenuButton(onSelected: onAccount),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPlanSheet(BuildContext context, ShellState state) {
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
        child: FreePlanCard(
          remaining: state.freeRemaining,
          total: state.freeTotal,
        ),
      ),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tab,
    required this.locked,
    required this.onSelect,
  });

  final ShellTab tab;
  final bool locked;
  final ValueChanged<ShellDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.borderSubtle,
            width: MettleSpace.border,
          ),
        ),
      ),
      child: NavigationBar(
        height: MettleSpace.bottomNavHeight,
        backgroundColor: colors.bgSidebar,
        indicatorColor: colors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: shellDestinations
            .indexWhere((d) => d.tab == tab)
            .clamp(0, shellDestinations.length - 1),
        onDestinationSelected: (index) => onSelect(shellDestinations[index]),
        destinations: [
          for (final destination in shellDestinations)
            NavigationDestination(
              icon: _NavIcon(
                icon: destination.icon,
                locked: destination.tab == ShellTab.progress && locked,
              ),
              label: destination.label,
              tooltip: destination.label,
            ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.locked});

  final IconData icon;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glyph = Icon(icon, size: 24);

    if (!locked) return glyph;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        glyph,
        Positioned(
          right: -4,
          top: -2,
          child: Icon(
            Icons.lock_outline_rounded,
            size: 12,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}
