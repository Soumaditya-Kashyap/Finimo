import 'package:flutter/material.dart';
import '../models/user_profile_data.dart';
import '../services/auth_repository.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/household_space_section.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/security_controls_section.dart';
import 'auth_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final HomeRepository repository;

  const UserProfileScreen({
    super.key,
    required this.repository,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserProfileData> _futureProfile;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _futureProfile = widget.repository.getUserProfileData().then((profile) {
      setState(() {
        _biometricEnabled = profile.biometricSecurityEnabled;
      });
      return profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<UserProfileData>(
          future: _futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryFixed,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading profile: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.dangerCoral),
                ),
              );
            }

            final profile = snapshot.data!;

            return Column(
              children: [
                // Custom Top Navigation Bar: Back | USER PROFILE | Gear | Profile Icon
                _buildTopBar(context),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 10,
                      bottom: MediaQuery.paddingOf(context).bottom + 24,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Profile Header Hero Card
                        ProfileHeaderCard(profile: profile),

                        const SizedBox(height: 24),

                        // 2. Active Household Space Section
                        HouseholdSpaceSection(
                          profile: profile,
                          onEditFamilyTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit Family Entity coming in Phase 2'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          onAddMemberTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Family Member Invite flow ready for API'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // 3. Security & App Controls Section
                        SecurityControlsSection(
                          profile: profile,
                          biometricEnabled: _biometricEnabled,
                          onBiometricChanged: (val) {
                            setState(() {
                              _biometricEnabled = val;
                            });
                          },
                          onCredentialManagementTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Credential & Key rotation coming soon'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // 4. Log Out of Space CTA Button
                        GestureDetector(
                          onTap: () {
                            _showLogoutConfirmation(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161014),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.dangerCoral.withValues(alpha: 0.18),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: AppColors.dangerCoral,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Log Out of Space',
                                  style: AppTypography.headlineSm(
                                    color: AppColors.dangerCoral,
                                    fontWeight: FontWeight.w700,
                                  ).copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 5. Authenticated terminal footer note
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTypography.caption(
                                  color: AppColors.textMuted,
                                ).copyWith(fontSize: 11, height: 1.4),
                                children: [
                                  const TextSpan(text: 'Authenticated as '),
                                  TextSpan(
                                    text: profile.email,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' on this secure\nterminal',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button + USER PROFILE title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const SizedBox(width: 6),
              Text(
                'USER PROFILE',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  letterSpacing: 0.5,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // Trailing Actions: Settings Gear + Active User Avatar Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('App Settings ready for Phase 2'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: AppColors.canvasBase,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface01,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.paddingOf(bottomSheetContext).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Log Out of Space?',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will need to re-authenticate with your passkey or biometric credentials to access Roy Family.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (ctx) => AuthScreen(
                              authRepository: MockAuthRepository(),
                              homeRepository: widget.repository,
                              initialMode: AuthMode.login,
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerCoral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
