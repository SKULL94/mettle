/// Base URL and paths. No URL strings in data sources.
abstract final class ApiConstants {
  /// Overridable at runtime from Settings (M2) so a reviewer can point the app
  /// at their own backend. `10.0.2.2` is the host machine from the Android
  /// emulator; `localhost` would resolve to the emulator itself.
  static const defaultBaseUrl = 'http://10.0.2.2:8000';
  static const webBaseUrl = 'http://localhost:8000';

  static const apiVersion = 'v1';

  static const sessions = '/$apiVersion/sessions';
  static const meta = '/$apiVersion/meta';
  static const health = '/healthz';

  static String session(String id) => '$sessions/$id';
  static String turnStream(String id) => '$sessions/$id/turns/stream';
  static String answer(String id) => '$sessions/$id/answer';
  static String skip(String id) => '$sessions/$id/skip';
  static String scorecard(String id) => '$sessions/$id/scorecard';

  /// Anonymous device identifier. Partitions data; does not authenticate.
  static const deviceIdHeader = 'X-Device-Id';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(minutes: 5);
}
