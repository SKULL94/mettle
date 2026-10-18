import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/app_preferences.dart';

/// The single container. No other global mutable state exists in the app.
final sl = GetIt.instance;

/// Composition root, called once from the splash bootstrap.
///
/// Registration order is fixed and the section comments are load-bearing:
/// external → data sources → repositories → use cases → blocs. Keeping it
/// manual means it is explicit and greppable with no build step; when this file
/// passes ~150 lines, split into per-feature `_initX()` functions called from
/// here rather than reaching for codegen.
Future<void> configureDependencies() async {
  // ── External ─────────────────────────────────────────────
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

  // ── Data sources ─────────────────────────────────────────
  // ── Repositories ─────────────────────────────────────────
  // ── Use cases ────────────────────────────────────────────
  // ── Blocs ────────────────────────────────────────────────
}

/// Test seam: drops every registration so each test starts clean.
Future<void> resetDependencies() => sl.reset();
