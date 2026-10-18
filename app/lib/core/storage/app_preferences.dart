import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

/// Typed access to the handful of values the app persists outside feature data.
///
/// Session history and scores live in the feature's own local store (M2); this
/// holds only app-wide settings and the anonymous device id.
final class AppPreferences {
  const AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kDeviceId = 'device_id';
  static const _kThemeMode = 'theme_mode';
  static const _kApiBaseUrl = 'api_base_url';

  /// Anonymous, device-local identifier, generated once on first launch.
  ///
  /// Its only job is scoping a conversation thread on the backend. It
  /// **partitions** data; it does not authenticate anyone, and nothing
  /// security-relevant may be built on it.
  Future<String> deviceId() async {
    final existing = _prefs.getString(_kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _uuidV4();
    await _prefs.setString(_kDeviceId, generated);
    return generated;
  }

  ThemeMode themeMode() {
    return switch (_prefs.getString(_kThemeMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);

  /// Overridable from Settings (M2) so the app can be pointed at any backend.
  String apiBaseUrl() {
    final stored = _prefs.getString(_kApiBaseUrl);
    if (stored != null && stored.isNotEmpty) return stored;
    return kIsWeb ? ApiConstants.webBaseUrl : ApiConstants.defaultBaseUrl;
  }

  Future<void> setApiBaseUrl(String url) => _prefs.setString(_kApiBaseUrl, url);

  /// RFC 4122 version 4. Hand-rolled to avoid a dependency for eight lines —
  /// this value is an opaque partition key, not a security token.
  static String _uuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
