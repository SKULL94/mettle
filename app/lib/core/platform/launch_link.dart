enum LaunchLink { none, verified, expired }

abstract final class LaunchLinkReader {
  static LaunchLink _pending = LaunchLink.none;

  static void capture(Uri uri) => _pending = _classify(uri);

  static LaunchLink take() {
    final pending = _pending;
    _pending = LaunchLink.none;
    return pending;
  }

  static LaunchLink _classify(Uri uri) {
    final query = uri.queryParameters;
    final fragment = uri.fragment.isEmpty
        ? const <String, String>{}
        : Uri.splitQueryString(uri.fragment);

    if (query.containsKey('error') ||
        query.containsKey('error_code') ||
        fragment.containsKey('error') ||
        fragment.containsKey('error_code')) {
      return LaunchLink.expired;
    }

    if (query.containsKey('code') || fragment.containsKey('access_token')) {
      return LaunchLink.verified;
    }

    return LaunchLink.none;
  }
}
