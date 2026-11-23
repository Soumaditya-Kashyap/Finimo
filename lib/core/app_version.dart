/// Central Application Versioning for FINIMO
///
/// Keeps application version constants synchronized with `pubspec.yaml`.
/// Standard semantic versioning: 1.1.1+1
class AppVersion {
  AppVersion._();

  /// Semantic version name (Major.Minor.Patch)
  static const String versionName = '1.1.1';

  /// Monotonically increasing build number
  static const int buildNumber = 1;

  /// Current development milestone
  static const String appPhase = 'Phase 1 MVP';

  /// Formatted display version string (e.g. 'FINIMO v1.1.1')
  static const String displayVersion = 'FINIMO v$versionName';

  /// Full version with build number (e.g. 'v1.1.1+1')
  static const String fullVersion = 'v$versionName+$buildNumber';
}
