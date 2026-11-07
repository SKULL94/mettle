abstract final class SupabaseConstants {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  static const isConfigured = url != '' && publishableKey != '';

  static const callbackScheme = 'com.zeeshanhaider.mettle';
  static const callbackHost = 'login-callback';
  static const redirectUrl = '$callbackScheme://$callbackHost';
}
