import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth_screen.dart';
import 'services/auth_repository.dart';
import 'services/home_repository.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark navigation bar and status bar matching OLED black theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.canvasBase,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FinimoApp());
}

class FinimoApp extends StatelessWidget {
  const FinimoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final homeRepository = MockHomeRepository();
    final authRepository = MockAuthRepository();

    return MaterialApp(
      title: 'FINIMO',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.canvasBase,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.canvasBase,
          primary: AppColors.primaryFixed,
          secondary: AppColors.secondary,
          error: AppColors.dangerCoral,
        ),
      ),
      home: AuthScreen(
        authRepository: authRepository,
        homeRepository: homeRepository,
        initialMode: AuthMode.login,
      ),
    );
  }
}
