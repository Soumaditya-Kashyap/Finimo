import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/core/app_version.dart';

void main() {
  group('AppVersion Configuration Tests', () {
    test('AppVersion constants have valid semantic versioning', () {
      expect(AppVersion.versionName, '1.1.1');
      expect(AppVersion.buildNumber, 1);
      expect(AppVersion.displayVersion, 'FINIMO v1.1.1');
      expect(AppVersion.fullVersion, 'v1.1.1+1');
      expect(AppVersion.appPhase, 'Phase 1 MVP');
    });

    test('AppVersion matches pubspec.yaml version entry', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);
      final content = pubspecFile.readAsStringSync();
      final expectedVersionLine =
          'version: ${AppVersion.versionName}+${AppVersion.buildNumber}';
      expect(content.contains(expectedVersionLine), isTrue,
          reason: 'pubspec.yaml version must match AppVersion constant');
    });
  });
}
