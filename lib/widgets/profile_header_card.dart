import 'package:flutter/material.dart';
import '../models/user_profile_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfileData profile;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Clean Architectural Avatar + Name/Email/Role
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Clean Avatar circle (no tacky AI-slop fuzzy halo, no awkward floating dot)
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface02,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      color: AppColors.primaryFixed,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name, Role Badge, Email, Verification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            style: AppTypography.headlineSm(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ).copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Role Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3035),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.tertiaryFixedDim.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            profile.roleBadge,
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              color: AppColors.tertiaryFixed,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: AppTypography.bodySm(
                        color: AppColors.textMuted,
                      ).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 13,
                          color: AppColors.primaryFixed,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Primary Account Owner',
                          style: AppTypography.bodySm(
                            color: AppColors.primaryFixed,
                          ).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (profile.finimoId.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '· ID ${profile.finimoId}',
                            style: AppTypography.caption(
                              color: AppColors.textMuted,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Bottom telemetry bar: ACCOUNT STATUS & DEVICE SESSION
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              children: [
                // Account Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACCOUNT STATUS',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryFixed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.syncState,
                            style: AppTypography.headlineSm(
                              color: AppColors.primaryFixed,
                              fontWeight: FontWeight.w700,
                            ).copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Divider line
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                const SizedBox(width: 16),

                // Device Session
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEVICE SESSION',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.sessionNode,
                        style: AppTypography.bodyMd(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
