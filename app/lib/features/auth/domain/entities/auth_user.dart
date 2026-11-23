class AuthUser {
  const AuthUser({
    required this.id,
    required this.isAnonymous,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
}
