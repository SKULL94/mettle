enum AppThemeMode {
  system,
  light,
  dark;

  static const defaultMode = AppThemeMode.dark;

  static AppThemeMode fromName(String? name) {
    if (name == null || name.isEmpty) return defaultMode;

    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => defaultMode,
    );
  }
}
