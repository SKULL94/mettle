import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_strings.dart';
import '../error/exceptions.dart';

final class ServerSentEvent {
  const ServerSentEvent(this.event, this.data);

  final String event;
  final Map<String, dynamic> data;
}

final class SseClient {
  const SseClient(this._client);

  final http.Client _client;

  Stream<ServerSentEvent> connect(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async* {
    final request = http.Request('GET', uri)
      ..headers.addAll({
        ...headers,
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      });

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on SocketException {
      throw const NetworkException(AppStrings.serverUnreachable);
    } on http.ClientException {
      throw const NetworkException(AppStrings.streamInterrupted);
    }

    if (response.statusCode != 200) {
      throw ServerException(
        'stream rejected with ${response.statusCode}',
        response.statusCode,
      );
    }

    String? event;
    final payload = <String>[];

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (line.isEmpty) {
        final decoded = _dispatch(event, payload);
        event = null;
        payload.clear();
        if (decoded != null) yield decoded;
        continue;
      }

      if (line.startsWith(':')) continue;

      final separator = line.indexOf(':');
      final field = separator == -1 ? line : line.substring(0, separator);
      var value = separator == -1 ? '' : line.substring(separator + 1);
      if (value.startsWith(' ')) value = value.substring(1);

      switch (field) {
        case 'event':
          event = value;
        case 'data':
          payload.add(value);
      }
    }

    final trailing = _dispatch(event, payload);
    if (trailing != null) yield trailing;
  }

  static ServerSentEvent? _dispatch(String? event, List<String> payload) {
    if (event == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload.join('\n'));
      if (decoded is! Map<String, dynamic>) return null;
      return ServerSentEvent(event, decoded);
    } on FormatException {
      return null;
    }
  }
}
