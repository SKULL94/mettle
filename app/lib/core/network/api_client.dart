import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../constants/app_strings.dart';
import '../error/exceptions.dart';
import '../storage/app_preferences.dart';

final class ApiClient {
  ApiClient(this._prefs, {http.Client? client})
    : _client = client ?? http.Client();

  final AppPreferences _prefs;
  final http.Client _client;

  http.Client get raw => _client;

  String get baseUrl => ApiConstants.isBackendConfigured
      ? ApiConstants.configuredBaseUrl
      : _prefs.apiBaseUrl();

  Uri uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> headers({bool json = false}) async => {
    if (json) 'Content-Type': 'application/json',
    ApiConstants.deviceIdHeader: await _prefs.deviceId(),
  };

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _send(
      () async => _client.get(uri(path), headers: await headers()),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _send(
      () async => _client.post(
        uri(path),
        headers: await headers(json: true),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<void> post(String path, Map<String, dynamic> body) async {
    final response = await _send(
      () async => _client.post(
        uri(path),
        headers: await headers(json: true),
        body: jsonEncode(body),
      ),
    );
    _guard(response);
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(ApiConstants.connectTimeout);
    } on TimeoutException {
      throw const NetworkException(AppStrings.requestTimeout);
    } on SocketException {
      throw const NetworkException(AppStrings.serverUnreachable);
    } on http.ClientException {
      throw const NetworkException(AppStrings.serverUnreachable);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    _guard(response);
    if (response.bodyBytes.isEmpty) return const <String, dynamic>{};
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException('unexpected response shape');
    }
    return decoded;
  }

  void _guard(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) return;
    throw ServerException(_detail(response), status);
  }

  static String _detail(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
    } on Object {
      return 'request failed with ${response.statusCode}';
    }
    return 'request failed with ${response.statusCode}';
  }
}
