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
          // Top Row: Avatar with neon ring + Name/Email/Role
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar circle with neon outer halo and status dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1B1B22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryFixed.withValues(alpha: 0.18),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF282834),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        profile.initials,
                        style: AppTypography.headlineSm(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                        ).copyWith(
                          fontSize: 22,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  // Green online indicator dot on the bottom right
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface01,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryFixed.withValues(alpha: 0.8),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                            ).copyWith(fontSize: 19),
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
                          Icons.verified_outlined,
                          size: 13,
                          color: AppColors.primaryFixed,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Verified Identity',
                          style: AppTypography.bodySm(
                            color: const Color(0xFFD4E3A0),
                          ).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '· FINIMO ID ${profile.finimoId}',
                          style: AppTypography.bodySm(
                            color: AppColors.textMuted,
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Bottom telemetry bar: SYNC STATE & SESSION NODE
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
                // Sync State
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYNC STATE',
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
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryFixed.withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
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

                // Session Node
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SESSION NODE',
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
