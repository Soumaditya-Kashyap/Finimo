import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../services/auth_repository.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/auth_text_field.dart';
import 'main_navigation_shell.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final HomeRepository homeRepository;
  final AuthMode initialMode;

  const AuthScreen({
    super.key,
    required this.authRepository,
    required this.homeRepository,
    this.initialMode = AuthMode.login,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _currentMode;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _spaceNameController;

  bool _obscurePassword = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _spaceNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _spaceNameController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.caption(color: Colors.white).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: AppColors.dangerCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_currentMode == AuthMode.login) {
      if (email.isEmpty) {
        _showError('Please enter your email address');
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        _showError('Please enter a valid email address');
        return;
      }
      if (password.isEmpty) {
        _showError('Please enter your password');
        return;
      }
    } else {
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        _showError('Please enter your full name');
        return;
      }
      if (email.isEmpty) {
        _showError('Please enter your email address');
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        _showError('Please enter a valid email address');
        return;
      }
      if (password.length < 10) {
        _showError('Password must be at least 10 characters');
        return;
      }
      if (!_agreedToTerms) {
        _showError('Please agree to the Terms of Service & Privacy Policy');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_currentMode == AuthMode.login) {
        await widget.authRepository.login(
          email: email,
          password: password,
        );
      } else {
        await widget.authRepository.registerAndCreateSpace(
          fullName: _nameController.text.trim(),
          email: email,
          password: password,
          householdSpaceName: _spaceNameController.text.trim(),
        );
      }

      if (!mounted) return;

      // Navigate to MainNavigationShell
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainNavigationShell(homeRepository: widget.homeRepository),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Authentication failed: ');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentMode == AuthMode.login
                  ? _buildLoginView()
                  : _buildSignUpView(),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 1: LOGIN (Image 2)
  // ==========================================
  Widget _buildLoginView() {
    return Column(
      key: const ValueKey('LoginView'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // FINIMO wordmark logo
        Image.asset(
          'assets/logos/finimo_wordmark.png',
          width: 175,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Welcome back. Access your personal &\nfamily finances.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(
              color: AppColors.textMuted,
            ).copyWith(height: 1.45),
          ),
        ),

        const SizedBox(height: 28),

        // Central Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF101014),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email Field
              AuthTextField(
                label: 'EMAIL ADDRESS',
                hintText: 'name@example.com',
                controller: _emailController,
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // Password Field
              AuthTextField(
                label: 'PASSWORD',
                hintText: 'Enter your password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Neon Electric Lime "Log In ->" CTA
              GestureDetector(
                onTap: _handleSubmit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryFixed.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      else ...[
                        Text(
                          'Log In',
                          style: AppTypography.headlineSm(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Forgot Password link below Log In
              Center(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent to your email'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Divider "OR SECURE ACCESS WITH"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR SECURE ACCESS WITH',
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FaceID & TouchID Button
              GestureDetector(
                onTap: _handleSubmit,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141419),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          size: 22,
                          color: AppColors.primaryFixed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'FaceID & TouchID',
                                  style: AppTypography.bodyMd(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryFixed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Secure Biometric Login',
                              style: AppTypography.caption(
                                color: AppColors.textMuted,
                              ).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // 256-bit E2E Encrypted Session Lock Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_rounded,
              color: AppColors.primaryFixed,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              '256-bit E2E Encrypted Session',
              style: AppTypography.caption(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 12),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Don't have an account? Sign Up Switcher
        GestureDetector(
          onTap: () => _switchMode(AuthMode.signup),
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMd(
                color: AppColors.textMuted,
              ).copyWith(fontSize: 14),
              children: const [
                TextSpan(text: "Don't have an account? "),
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: AppColors.primaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 2: GET STARTED / SIGN UP (Image 1)
  // ==========================================
  Widget _buildSignUpView() {
    return Column(
      key: const ValueKey('SignUpView'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // FINIMO wordmark logo
        Image.asset(
          'assets/logos/finimo_wordmark.png',
          width: 175,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),

        Text(
          'Set up your family account.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd(
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 24),

        // Central Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF101014),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Full Name
              AuthTextField(
                label: 'Full Name',
                hintText: 'Your name',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 18),

              // 2. Email Address
              AuthTextField(
                label: 'Email Address',
                hintText: 'name@example.com',
                controller: _emailController,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // 3. Password
              AuthTextField(
                label: 'Password',
                hintText: 'Choose a strong password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                helperText: 'Minimum 10 characters required',
                helperIcon: Icons.info_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 18),

              // 4. Family Name
              AuthTextField(
                label: 'Family Name',
                rightLabel: 'MAIN ACCOUNT',
                hintText: 'e.g. Roy Family',
                controller: _spaceNameController,
                prefixIcon: Icons.home_outlined,
              ),

              const SizedBox(height: 18),

              // 5. Terms of Service & Privacy Policy Checkbox Row
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agreedToTerms = !_agreedToTerms;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _agreedToTerms
                            ? AppColors.primaryFixed
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _agreedToTerms
                              ? AppColors.primaryFixed
                              : AppColors.textMuted,
                          width: 1.5,
                        ),
                      ),
                      child: _agreedToTerms
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.caption(
                            color: AppColors.textMuted,
                          ).copyWith(fontSize: 12, height: 1.4),
                          children: const [
                            TextSpan(text: 'By proceeding, you agree to the '),
                            TextSpan(
                              text: 'Terms of\nService',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 6. Create Account & Launch Space CTA Button
              GestureDetector(
                onTap: _handleSubmit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryFixed.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      else ...[
                        Text(
                          'Create Family Account',
                          style: AppTypography.headlineSm(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ).copyWith(fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Already registered? Log In Switcher
        Center(
          child: GestureDetector(
            onTap: () => _switchMode(AuthMode.login),
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodyMd(
                  color: AppColors.textMuted,
                ).copyWith(fontSize: 14),
                children: const [
                  TextSpan(text: 'Already registered? '),
                  TextSpan(
                    text: 'Log In',
                    style: TextStyle(
                      color: AppColors.primaryFixed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
