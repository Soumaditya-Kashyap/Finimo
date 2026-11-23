import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/family_member.dart';
import '../models/user_profile_data.dart';
import '../services/auth_repository.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/household_space_section.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/security_controls_section.dart';
import 'auth_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final HomeRepository repository;
  final AuthRepository? authRepository;
  final FamilyRepository? familyRepository;

  const UserProfileScreen({
    super.key,
    required this.repository,
    this.authRepository,
    this.familyRepository,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final AuthRepository _authRepo;
  late final FamilyRepository _familyRepo;
  late Future<UserProfileData> _futureProfile;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _authRepo = widget.authRepository ?? HttpAuthRepository();
    _familyRepo = widget.familyRepository ?? HttpFamilyRepository();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _futureProfile = _authRepo.getCurrentProfile().then((profile) {
        if (mounted) {
          setState(() {
            _biometricEnabled = profile.biometricSecurityEnabled;
          });
        }
        return profile;
      }).catchError((_) async {
        // Prefer locally cached real user profile over mock fallback
        final cached = await TokenStorage().getCachedUserProfile();
        if (cached != null) {
          final cachedProfile = UserProfileData.fromJson(cached);
          if (mounted) {
            setState(() {
              _biometricEnabled = cachedProfile.biometricSecurityEnabled;
            });
          }
          return cachedProfile;
        }

        // Fallback for tests or offline state
        final fallback = await widget.repository.getUserProfileData();
        if (mounted) {
          setState(() {
            _biometricEnabled = fallback.biometricSecurityEnabled;
          });
        }
        return fallback;
      });
    });
  }

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.caption(
            color: isError ? Colors.white : Colors.black,
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor:
            isError ? AppColors.dangerCoral : AppColors.primaryFixed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
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

            if (snapshot.hasError && snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error loading profile',
                      style: AppTypography.bodyMd(color: AppColors.dangerCoral),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryFixed,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final profile = snapshot.data!;

            return Column(
              children: [
                // Top Navigation Bar
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
                          onEditFamilyTap: () =>
                              _showEditFamilyNameSheet(context, profile),
                          onEditCurrencyTap: () =>
                              _showEditCurrencyTimezoneSheet(context, profile),
                          onAddMemberTap: () =>
                              _showAddFamilyMemberSheet(context, profile),
                          onViewMembersTap: () =>
                              _showFamilyMembersSheet(context, profile),
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
                          onCredentialManagementTap: () =>
                              _showChangePasswordSheet(context, profile),
                        ),

                        const SizedBox(height: 28),

                        // 4. Log Out CTA Button
                        GestureDetector(
                          onTap: () {
                            _showLogoutConfirmation(context, profile);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161014),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.dangerCoral
                                    .withValues(alpha: 0.18),
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
                                  'Log Out',
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

                        // 5. Authenticated device footer note
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
                                  const TextSpan(text: 'Signed in as '),
                                  TextSpan(
                                    text: profile.email,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' on this device',
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  _showNotification('Profile and Family synced with Live Core');
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

  // ==========================================
  // ACTION 1: EDIT FAMILY NAME
  // ==========================================
  void _showEditFamilyNameSheet(BuildContext context, UserProfileData profile) {
    final controller =
        TextEditingController(text: profile.familyEntityName);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101014),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.paddingOf(ctx).bottom +
                    MediaQuery.viewInsetsOf(ctx).bottom +
                    20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Edit Family Name',
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Update the household space name for your family circle.',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    label: 'FAMILY NAME',
                    hintText: 'e.g. Roy Family',
                    controller: controller,
                    prefixIcon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
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
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final newName = controller.text.trim();
                                  if (newName.isEmpty) {
                                    _showNotification(
                                        'Please enter a family name',
                                        isError: true);
                                    return;
                                  }
                                  setSheetState(() => isSaving = true);
                                  try {
                                    await _familyRepo.updateFamily(
                                      familyName: newName,
                                    );
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                    _loadProfile();
                                    _showNotification(
                                      'Family name updated to "$newName"',
                                    );
                                  } on ApiException catch (e) {
                                    setSheetState(() => isSaving = false);
                                    _showNotification(e.message, isError: true);
                                  } catch (e) {
                                    setSheetState(() => isSaving = false);
                                    _showNotification('Failed to update family name',
                                        isError: true);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryFixed,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
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
      },
    );
  }

  // ==========================================
  // ACTION 2: EDIT CURRENCY & TIMEZONE
  // ==========================================
  void _showEditCurrencyTimezoneSheet(
      BuildContext context, UserProfileData profile) {
    String selectedCurrency = profile.currency;
    String selectedTimezone = profile.timezone;
    bool isSaving = false;

    final currencies = [
      {'code': 'INR', 'symbol': '₹', 'label': 'INR (₹)'},
      {'code': 'USD', 'symbol': '\$', 'label': 'USD (\$)'},
      {'code': 'EUR', 'symbol': '€', 'label': 'EUR (€)'},
      {'code': 'GBP', 'symbol': '£', 'label': 'GBP (£)'},
    ];

    final timezones = [
      'Asia/Kolkata',
      'UTC',
      'America/New_York',
      'Europe/London',
      'Asia/Dubai',
      'Asia/Singapore',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101014),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.paddingOf(ctx).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Currency & Timezone',
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select ledger currency and accounting timezone for transactions.',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'PRIMARY CURRENCY',
                    style: AppTypography.caption(color: AppColors.textMuted)
                        .copyWith(fontSize: 10, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: currencies.map((curr) {
                      final isSelected = selectedCurrency == curr['code'];
                      return ChoiceChip(
                        label: Text(
                          curr['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryFixed,
                        backgroundColor: AppColors.surface02,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryFixed
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                        onSelected: (val) {
                          setSheetState(() {
                            selectedCurrency = curr['code']!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'OPERATIONAL TIMEZONE',
                    style: AppTypography.caption(color: AppColors.textMuted)
                        .copyWith(fontSize: 10, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timezones.map((tz) {
                      final isSelected = selectedTimezone == tz;
                      return ChoiceChip(
                        label: Text(
                          tz,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.tertiaryFixed,
                        backgroundColor: AppColors.surface02,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.tertiaryFixed
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                        onSelected: (val) {
                          setSheetState(() {
                            selectedTimezone = tz;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
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
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setSheetState(() => isSaving = true);
                                  try {
                                    await _familyRepo.updateFamily(
                                      currency: selectedCurrency,
                                      timezone: selectedTimezone,
                                    );
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                    _loadProfile();
                                    _showNotification(
                                      'Currency & Timezone updated successfully',
                                    );
                                  } on ApiException catch (e) {
                                    setSheetState(() => isSaving = false);
                                    _showNotification(e.message, isError: true);
                                  } catch (e) {
                                    setSheetState(() => isSaving = false);
                                    _showNotification(
                                        'Failed to update currency settings',
                                        isError: true);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryFixed,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Save Settings',
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
      },
    );
  }

  // ==========================================
  // ACTION 3: ADD FAMILY MEMBER
  // ==========================================
  void _showAddFamilyMemberSheet(
      BuildContext context, UserProfileData profile) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRelation = 'SPOUSE';
    String selectedRole = 'MEMBER';
    bool isInviteMode = false;
    bool isSaving = false;

    final relations = ['SPOUSE', 'CHILD', 'PARENT', 'SIBLING', 'OTHER'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101014),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.paddingOf(ctx).bottom +
                    MediaQuery.viewInsetsOf(ctx).bottom +
                    20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '+ Add Family Member',
                      style: AppTypography.headlineSm(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add a dependent to the household or send an invitation link.',
                      style: AppTypography.bodySm(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    // Mode Toggle: Dependent vs Invite
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surface02,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setSheetState(() => isInviteMode = false);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !isInviteMode
                                      ? AppColors.surface03
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Add Dependent',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !isInviteMode
                                        ? AppColors.primaryFixed
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setSheetState(() => isInviteMode = true);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isInviteMode
                                      ? AppColors.surface03
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Invite by Email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isInviteMode
                                        ? AppColors.primaryFixed
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'MEMBER FULL NAME',
                      hintText: 'e.g. Priya Mehta',
                      controller: nameController,
                      prefixIcon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'RELATION TO OWNER',
                      style: AppTypography.caption(color: AppColors.textMuted)
                          .copyWith(fontSize: 10, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: relations.map((rel) {
                        final isSelected = selectedRelation == rel;
                        return ChoiceChip(
                          label: Text(
                            rel,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.tertiaryFixed,
                          backgroundColor: AppColors.surface02,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.tertiaryFixed
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                          onSelected: (val) {
                            setSheetState(() => selectedRelation = rel);
                          },
                        );
                      }).toList(),
                    ),

                    if (isInviteMode) ...[
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'INVITE EMAIL (OPTIONAL)',
                        hintText: 'name@example.com',
                        controller: emailController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'ACCESS ROLE',
                        style: AppTypography.caption(color: AppColors.textMuted)
                            .copyWith(fontSize: 10, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('MEMBER'),
                            selected: selectedRole == 'MEMBER',
                            selectedColor: AppColors.primaryFixed,
                            backgroundColor: AppColors.surface02,
                            labelStyle: TextStyle(
                              color: selectedRole == 'MEMBER'
                                  ? Colors.black
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            onSelected: (val) {
                              setSheetState(() => selectedRole = 'MEMBER');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('ADMIN'),
                            selected: selectedRole == 'ADMIN',
                            selectedColor: AppColors.primaryFixed,
                            backgroundColor: AppColors.surface02,
                            labelStyle: TextStyle(
                              color: selectedRole == 'ADMIN'
                                  ? Colors.black
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            onSelected: (val) {
                              setSheetState(() => selectedRole = 'ADMIN');
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
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
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) {
                                      _showNotification(
                                          'Please enter member name',
                                          isError: true);
                                      return;
                                    }
                                    setSheetState(() => isSaving = true);
                                    try {
                                      if (isInviteMode) {
                                        final email =
                                            emailController.text.trim();
                                        final inv =
                                            await _familyRepo.createInvitation(
                                          role: selectedRole,
                                          invitedEmail:
                                              email.isNotEmpty ? email : null,
                                        );
                                        if (ctx.mounted) Navigator.of(ctx).pop();
                                        _loadProfile();
                                        final inviteUrl =
                                            inv['invite_url'] ?? '';
                                        _showNotification(
                                          inviteUrl.isNotEmpty
                                              ? 'Invitation link created: $inviteUrl'
                                              : 'Invitation created successfully',
                                        );
                                      } else {
                                        await _familyRepo.createFamilyMember(
                                          name: name,
                                          relationType: selectedRelation,
                                        );
                                        if (ctx.mounted) Navigator.of(ctx).pop();
                                        _loadProfile();
                                        _showNotification(
                                          'Family member "$name" added successfully',
                                        );
                                      }
                                    } on ApiException catch (e) {
                                      setSheetState(() => isSaving = false);
                                      _showNotification(e.message, isError: true);
                                    } catch (e) {
                                      setSheetState(() => isSaving = false);
                                      _showNotification(
                                          'Failed to add member: ${e.toString()}',
                                          isError: true);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryFixed,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    isInviteMode
                                        ? 'Send Invite'
                                        : 'Add to Family',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ACTION: VIEW & MANAGE FAMILY MEMBERS
  // ==========================================
  void _showFamilyMembersSheet(
      BuildContext context, UserProfileData profile) {
    Future<List<FamilyMember>> futureMembers =
        _familyRepo.getFamilyMembers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101014),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.paddingOf(ctx).bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Header Row with Title + Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Family Circle Members',
                              style: AppTypography.headlineSm(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Manage household access & dependents',
                              style: AppTypography.caption(
                                color: AppColors.textMuted,
                              ).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _showAddFamilyMemberSheet(context, profile);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryFixed.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  size: 15,
                                  color: AppColors.primaryFixed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Add Member',
                                  style: AppTypography.caption(
                                    color: AppColors.primaryFixed,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Members List
                    Flexible(
                      child: FutureBuilder<List<FamilyMember>>(
                        future: futureMembers,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryFixed,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Failed to load members',
                                      style: AppTypography.bodySm(
                                        color: AppColors.dangerCoral,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        setSheetState(() {
                                          futureMembers =
                                              _familyRepo.getFamilyMembers();
                                        });
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final members = snapshot.data ?? [];
                          if (members.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'No family members found.',
                                  style: AppTypography.bodyMd(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: members.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final member = members[index];
                              final isOwnerOrAdmin =
                                  member.role == 'OWNER' ||
                                  member.role == 'ADMIN' ||
                                  member.relationType == MemberRelation.self ||
                                  member.relationType == MemberRelation.admin;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface02,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Avatar circle
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.surface03,
                                        border: Border.all(
                                          color: isOwnerOrAdmin
                                              ? AppColors.primaryFixed
                                                  .withValues(alpha: 0.3)
                                              : Colors.white
                                                  .withValues(alpha: 0.08),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          member.initial,
                                          style: TextStyle(
                                            fontFamily: 'SpaceGrotesk',
                                            color: isOwnerOrAdmin
                                                ? AppColors.primaryFixed
                                                : AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name + Relation/Role Badges
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.name,
                                            style: AppTypography.headlineSm(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ).copyWith(fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (isOwnerOrAdmin)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF0F3035),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: AppColors
                                                          .tertiaryFixedDim
                                                          .withValues(alpha: 0.3),
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Owner / Admin',
                                                    style: TextStyle(
                                                      fontFamily: 'SpaceGrotesk',
                                                      color: AppColors.tertiaryFixed,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.06),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(alpha: 0.08),
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    member.relationType.name
                                                        .toUpperCase(),
                                                    style: AppTypography.caption(
                                                      color: AppColors.textMuted,
                                                    ).copyWith(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              if (member.status != null &&
                                                  member.status!.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  '· ${member.status}',
                                                  style: AppTypography.caption(
                                                    color: AppColors.textMuted,
                                                  ).copyWith(fontSize: 10),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action / Status: Delete button or Protected tag
                                    if (isOwnerOrAdmin)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.04),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.shield_outlined,
                                              size: 13,
                                              color: AppColors.textMuted,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Primary',
                                              style: TextStyle(
                                                fontFamily: 'SpaceGrotesk',
                                                color: AppColors.textMuted,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      IconButton(
                                        tooltip: 'Remove from Family',
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 19,
                                          color: AppColors.dangerCoral,
                                        ),
                                        onPressed: () => _confirmDeleteMember(
                                          context,
                                          member,
                                          () {
                                            setSheetState(() {
                                              futureMembers = _familyRepo
                                                  .getFamilyMembers();
                                            });
                                            _loadProfile();
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMember(
    BuildContext context,
    FamilyMember member,
    VoidCallback onDeleted,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF141419),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.person_remove_outlined,
                    color: AppColors.dangerCoral,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Remove ${member.name}?',
                      style: AppTypography.headlineSm(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to remove ${member.name} from the family circle? Their historical transactions and ledger records will be preserved.',
                style: AppTypography.bodySm(color: AppColors.textMuted).copyWith(
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed:
                      isDeleting ? null : () => Navigator.of(dialogCtx).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          try {
                            await _familyRepo.deleteFamilyMember(member.id);
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                            }
                            onDeleted();
                            _showNotification(
                              '${member.name} removed from family',
                            );
                          } on ApiException catch (e) {
                            setDialogState(() => isDeleting = false);
                            _showNotification(e.message, isError: true);
                          } catch (e) {
                            setDialogState(() => isDeleting = false);
                            _showNotification(
                              'Failed to remove member: ${e.toString()}',
                              isError: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Remove Member',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ACTION 4: PASSWORD & SECURITY CHANGE
  // ==========================================
  void _showChangePasswordSheet(BuildContext context, UserProfileData profile) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101014),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.paddingOf(ctx).bottom +
                    MediaQuery.viewInsetsOf(ctx).bottom +
                    20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Password & Security',
                      style: AppTypography.headlineSm(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Update your password. For your security, other active sessions will be revoked.',
                      style: AppTypography.bodySm(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),

                    // Current Password
                    AuthTextField(
                      label: 'CURRENT PASSWORD',
                      hintText: 'Enter your existing password',
                      controller: currentPasswordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: obscureCurrent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setSheetState(() => obscureCurrent = !obscureCurrent);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // New Password
                    AuthTextField(
                      label: 'NEW PASSWORD',
                      hintText: 'Choose a strong password',
                      controller: newPasswordController,
                      prefixIcon: Icons.lock_reset_rounded,
                      obscureText: obscureNew,
                      helperText: 'Minimum 10 characters required',
                      helperIcon: Icons.info_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setSheetState(() => obscureNew = !obscureNew);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm New Password
                    AuthTextField(
                      label: 'CONFIRM NEW PASSWORD',
                      hintText: 'Re-enter your new password',
                      controller: confirmPasswordController,
                      prefixIcon: Icons.check_circle_outline_rounded,
                      obscureText: obscureNew,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
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
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final currentPass =
                                        currentPasswordController.text;
                                    final newPass = newPasswordController.text;
                                    final confirmPass =
                                        confirmPasswordController.text;

                                    if (currentPass.isEmpty) {
                                      _showNotification(
                                          'Please enter current password',
                                          isError: true);
                                      return;
                                    }
                                    if (newPass.length < 10) {
                                      _showNotification(
                                          'New password must be at least 10 characters',
                                          isError: true);
                                      return;
                                    }
                                    if (newPass != confirmPass) {
                                      _showNotification(
                                          'New passwords do not match',
                                          isError: true);
                                      return;
                                    }

                                    setSheetState(() => isSaving = true);
                                    try {
                                      await _authRepo.changePassword(
                                        currentPassword: currentPass,
                                        newPassword: newPass,
                                      );
                                      if (ctx.mounted) Navigator.of(ctx).pop();
                                      _showNotification(
                                        'Password updated successfully! Please sign in again.',
                                      );
                                      if (!context.mounted) return;
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (_) => AuthScreen(
                                            authRepository: _authRepo,
                                            homeRepository: widget.repository,
                                            initialMode: AuthMode.login,
                                          ),
                                        ),
                                        (route) => false,
                                      );
                                    } on ApiException catch (e) {
                                      setSheetState(() => isSaving = false);
                                      _showNotification(e.message, isError: true);
                                    } catch (e) {
                                      setSheetState(() => isSaving = false);
                                      _showNotification(
                                          'Failed to update password',
                                          isError: true);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryFixed,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Update Password',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ACTION 5: LOG OUT
  // ==========================================
  void _showLogoutConfirmation(BuildContext context, UserProfileData profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101014),
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
                'Log Out?',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will need to sign in again to access ${profile.familyEntityName}.',
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
                      onPressed: () async {
                        Navigator.of(bottomSheetContext).pop();
                        await _authRepo.logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (ctx) => AuthScreen(
                              authRepository: _authRepo,
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
