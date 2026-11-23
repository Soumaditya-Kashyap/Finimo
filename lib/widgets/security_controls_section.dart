import 'package:flutter/material.dart';
import '../models/user_profile_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SecurityControlsSection extends StatelessWidget {
  final UserProfileData profile;
  final bool biometricEnabled;
  final ValueChanged<bool>? onBiometricChanged;
  final VoidCallback? onCredentialManagementTap;

  const SecurityControlsSection({
    super.key,
    required this.profile,
    required this.biometricEnabled,
    this.onBiometricChanged,
    this.onCredentialManagementTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SECURITY & CONTROLS',
              style: AppTypography.caption(
                color: AppColors.textMuted,
              ).copyWith(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Biometric Ready',
              style: AppTypography.caption(
                color: AppColors.textMuted,
              ).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main Container wrapping the 3 security tiles
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface01,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 1. Biometric Security with Electric Lime Switch
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface02,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface03,
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
                          Text(
                            'Biometric Security',
                            style: AppTypography.bodyMd(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'FaceID / TouchID unlock',
                            style: AppTypography.bodySm(
                              color: AppColors.textMuted,
                            ).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Electric Lime Custom-styled Switch
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: biometricEnabled,
                        onChanged: onBiometricChanged,
                        activeThumbColor: AppColors.canvasBase,
                        activeTrackColor: AppColors.primaryFixed,
                        inactiveThumbColor: AppColors.textMuted,
                        inactiveTrackColor: AppColors.surface03,
                        trackOutlineColor:
                            WidgetStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 2. Credential Management Tile (clickable chevron)
              GestureDetector(
                onTap: onCredentialManagementTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface02,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface03,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password & Security',
                              style: AppTypography.bodyMd(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ).copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Change password & security',
                              style: AppTypography.bodySm(
                                color: AppColors.textMuted,
                              ).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 3. App Version Tile
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface02,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface03,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Version',
                            style: AppTypography.bodyMd(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Release information',
                            style: AppTypography.bodySm(
                              color: AppColors.textMuted,
                            ).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // App Version Pill Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13131A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            profile.appVersion,
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            profile.appPhase,
                            style: AppTypography.caption(
                              color: AppColors.textMuted,
                            ).copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
