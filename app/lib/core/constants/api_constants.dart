abstract final class ApiConstants {
  static const defaultBaseUrl = 'http://10.0.2.2:8000';
  static const webBaseUrl = 'http://localhost:8000';

  static const configuredBaseUrl = String.fromEnvironment('METTLE_BASE_URL');
  static const isBackendConfigured = configuredBaseUrl != '';

  static const apiVersion = 'v1';

  static const sessions = '/$apiVersion/sessions';
  static const meta = '/$apiVersion/meta';
  static const health = '/healthz';

  static String session(String id) => '$sessions/$id';
  static String turnStream(String id) => '$sessions/$id/turns/stream';
  static String answer(String id) => '$sessions/$id/answer';
  static String skip(String id) => '$sessions/$id/skip';
  static String scorecard(String id) => '$sessions/$id/scorecard';

  static const deviceIdHeader = 'X-Device-Id';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(minutes: 5);
}
