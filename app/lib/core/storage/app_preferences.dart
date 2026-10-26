import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

final class AppPreferences {
  const AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kDeviceId = 'device_id';
  static const _kThemeMode = 'theme_mode';
  static const _kApiBaseUrl = 'api_base_url';

  Future<String> deviceId() async {
    final existing = _prefs.getString(_kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _uuidV4();
    await _prefs.setString(_kDeviceId, generated);
    return generated;
  }

  String? themeMode() => _prefs.getString(_kThemeMode);

  Future<void> setThemeMode(String name) => _prefs.setString(_kThemeMode, name);

  String apiBaseUrl() {
    final stored = _prefs.getString(_kApiBaseUrl);
    if (stored != null && stored.isNotEmpty) return stored;
    return kIsWeb ? ApiConstants.webBaseUrl : ApiConstants.defaultBaseUrl;
  }

  Future<void> setApiBaseUrl(String url) => _prefs.setString(_kApiBaseUrl, url);

  static String _uuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
