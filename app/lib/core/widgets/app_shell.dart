import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../di/injection.dart';
import '../network/api_client.dart';
import 'app_sidebar.dart';
import 'app_top_bar.dart';
import 'nav_destination.dart';
import 'window_size.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.body,
    required this.selectedIndex,
    required this.onStartSession,
    this.onDestinationSelected,
    this.sessionActive = false,
    this.topBarLead,
    this.topBarActions = const [],
    super.key,
  });

  static const noSelection = -1;

  final Widget body;
  final int selectedIndex;
  final VoidCallback onStartSession;
  final ValueChanged<int>? onDestinationSelected;
  final bool sessionActive;
  final Widget? topBarLead;
  final List<Widget> topBarActions;

  void _select(BuildContext context, int index) {
    final handler = onDestinationSelected;
    if (handler != null) {
      handler(index);
      return;
    }
    context.go(navDestinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isWideWindow) return _CompactShell(shell: this);

    final user = sl<AuthRepository>().currentUser;
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: selectedIndex,
            onSelected: (index) => _select(context, index),
            onStartSession: onStartSession,
            sessionActive: sessionActive,
            accountName:
                user?.displayName ?? user?.email ?? AppStrings.accountFallback,
            accountDetail: user?.email ?? AppStrings.signedOut,
            backendHost: _host(sl<ApiClient>().baseUrl),
          ),
          Expanded(
            child: Column(
              children: [
                // AppTopBar(
                //   onStartSession: onStartSession,
                //   onAccountPressed: () =>
                //       _select(context, navDestinations.length - 1),
                //   lead: topBarLead ?? TopBarPath(location: location),
                //   actions: topBarActions,
                // ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _host(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) return baseUrl;
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }
}

class _CompactShell extends StatelessWidget {
  const _CompactShell({required this.shell});

  final AppShell shell;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: shell.body,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant,
              width: AppDimens.hairline,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.selectedIndex.clamp(
            0,
            navDestinations.length - 1,
          ),
          onDestinationSelected: (index) => shell._select(context, index),
          destinations: [
            for (final destination in navDestinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
                tooltip: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}
