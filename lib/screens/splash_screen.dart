import 'package:flutter/material.dart';
import '../models/user_profile_data.dart';
import '../services/auth_repository.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/finimo_animated_logo.dart';
import 'auth_screen.dart';
import 'main_navigation_shell.dart';

/// Splash screen displaying the choreographed Finimo intro animation:
/// 1. Centred colour-cycling [FinimoAnimatedLogo] mark on OLED black background.
/// 2. Logo lifts smoothly upwards while the FINIMO wordmark slides out from beneath it.
/// 3. Seamlessly transitions into [AuthScreen] or [MainNavigationShell].
class SplashScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final HomeRepository homeRepository;

  const SplashScreen({
    super.key,
    required this.authRepository,
    required this.homeRepository,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;
  late final Animation<double> _liftAnimation;
  late final Animation<Offset> _wordmarkSlideAnimation;
  late final Animation<double> _wordmarkFadeAnimation;

  static const String _wordmarkAsset = 'assets/logos/finimo_wordmark.png';

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Initial offset shifts the column down so the icon is mathematically centered on launch.
    // As the controller progresses, the column moves up by ~28px to center the full lockup.
    _liftAnimation = Tween<double>(
      begin: 28.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Wordmark slides down into place from directly beneath the icon
    _wordmarkSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Wordmark smoothly fades in as it slides out
    _wordmarkFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // 1. Initial window allowing the user to experience the centered color-cycling mark
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // 2. Trigger the choreographed reveal (icon lifts up, wordmark slides out from under)
    _revealController.forward();

    // 3. Concurrently check auth session and ensure the completed brand lockup is appreciated
    final List<dynamic> results = await Future.wait([
      widget.authRepository.checkCurrentSession(),
      Future.delayed(const Duration(milliseconds: 2100)),
    ]);

    if (!mounted) return;

    final UserProfileData? activeUser = results[0] as UserProfileData?;

    final Widget destination = activeUser != null
        ? MainNavigationShell(homeRepository: widget.homeRepository)
        : AuthScreen(
            authRepository: widget.authRepository,
            homeRepository: widget.homeRepository,
          );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 175.0;
    const double wordmarkWidth = 185.0;
    const double spacing = 18.0;

    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: Center(
        child: AnimatedBuilder(
          animation: _revealController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _liftAnimation.value),
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Continuously color-cycling animated Finimo logo mark
              const FinimoAnimatedLogo(
                size: iconSize,
                duration: Duration(milliseconds: 2400),
              ),

              const SizedBox(height: spacing),

              // 2. Sliding & fading FINIMO wordmark
              SlideTransition(
                position: _wordmarkSlideAnimation,
                child: FadeTransition(
                  opacity: _wordmarkFadeAnimation,
                  child: Image.asset(
                    _wordmarkAsset,
                    width: wordmarkWidth,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
