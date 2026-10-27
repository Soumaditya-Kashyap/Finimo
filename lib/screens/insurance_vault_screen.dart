import 'package:flutter/material.dart';
import '../models/insurance_policy_model.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/insurance_policy_card.dart';
import '../widgets/insurance_vault_hero_card.dart';
import 'user_profile_screen.dart';

class InsuranceVaultScreen extends StatefulWidget {
  final HomeRepository repository;

  const InsuranceVaultScreen({
    super.key,
    required this.repository,
  });

  @override
  State<InsuranceVaultScreen> createState() => _InsuranceVaultScreenState();
}

class _InsuranceVaultScreenState extends State<InsuranceVaultScreen> {
  late Future<InsuranceVaultOverview> _futureOverview;
  String _selectedFilter = 'All Policies (3)';

  final List<String> _filters = [
    'All Policies (3)',
    'Health (1)',
    'Term Life (1)',
    'Automobile (1)',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureOverview = widget.repository.getInsuranceVaultOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: SafeArea(
        child: FutureBuilder<InsuranceVaultOverview>(
          future: _futureOverview,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryFixed),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading insurance vault: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.dangerCoral),
                ),
              );
            }

            final overview = snapshot.data!;
            final filteredPolicies = _filterPolicies(overview.policies);

            return Column(
              children: [
                // 1. Top App Bar: STATUS with neon dot, notifications, profile
                _buildTopHeader(context),

                // 2. Sub-Header: Back chevron + FINANCIAL IMMUNITY / Protection & Policies + Protection shield icon
                _buildSubHeader(context),

                // 3. Scrollable Content Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Card: Total Protection Umbrella ₹1.25 Cr
                        InsuranceVaultHeroCard(overview: overview),

                        const SizedBox(height: 18),

                        // Filter Pill Switcher Carousel
                        _buildFilterRow(),

                        const SizedBox(height: 22),

                        // Section Title: Active Safeguards & Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Safeguards',
                              style: AppTypography.headlineSm(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 18),
                            ),
                            Text(
                              '${overview.policies.length} ACTIVE',
                              style: AppTypography.caption(
                                color: AppColors.textMuted,
                              ).copyWith(
                                fontSize: 10,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // List of Policies (Term Life, Health Floater, Motor Asset)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredPolicies.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final policy = filteredPolicies[index];
                            return InsurancePolicyCard(
                              policy: policy,
                              onPdfTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Downloading ${policy.policyName} PDF...',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              onTpaCardTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Displaying Instant Cashless TPA QR'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              onRenewTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Initiating Auto Renewal via Sinking Fund'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Emergency Claim Locker Section
                        _buildEmergencyClaimLocker(),

                        const SizedBox(height: 28),
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

  // Top header matching main FINIMO Status app bar
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'STATUS',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ).copyWith(fontSize: 15, letterSpacing: 0.5),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          UserProfileScreen(repository: widget.repository),
                    ),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.canvasBase,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sub-header with back button and screen title
  Widget _buildSubHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface02,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FINANCIAL IMMUNITY',
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      color: AppColors.tertiaryFixedDim,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Protection & Policies',
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.tertiaryFixedDim,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // Filter Pill Carousel [All Policies] [Health] [Term Life] [Automobile]
  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final filter in _filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedFilter == filter
                        ? AppColors.tertiaryFixed
                        : AppColors.surface01,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: _selectedFilter == filter
                          ? AppColors.tertiaryFixed
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                    boxShadow: _selectedFilter == filter
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.tertiaryFixed.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: _selectedFilter == filter
                          ? Colors.black
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: _selectedFilter == filter
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Emergency Claim Locker Section
  Widget _buildEmergencyClaimLocker() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.tertiaryFixed,
              ),
              const SizedBox(width: 8),
              Text(
                'Emergency Claim Locker',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Offline encrypted repository with local biometric credentials for instant hospital desk handovers.',
            style: AppTypography.bodySm(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Unlock Secure Locker (Biometric) Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unlocking Biometric Policy Locker...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF13171A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.fingerprint_rounded,
                    size: 20,
                    color: AppColors.tertiaryFixed,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Unlock Secure Locker\n(Biometric)',
                      style: AppTypography.bodySm(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
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

          const SizedBox(height: 16),

          // INSTANT 24x7 CLAIM DESKS
          Text(
            'INSTANT 24X7 CLAIM DESKS',
            style: AppTypography.caption(
              color: AppColors.textMuted,
            ).copyWith(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          // Two claim desk cards: CARE HEALTH TPA & HDFC LIFE DESK
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface02,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'CARE HEALTH TPA',
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                color: AppColors.primaryFixed,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppColors.primaryFixed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1800-102-4488',
                        style: AppTypography.bodySm(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface02,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'HDFC LIFE DESK',
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                color: AppColors.tertiaryFixedDim,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppColors.tertiaryFixedDim,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1800-266-1234',
                        style: AppTypography.bodySm(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<InsurancePolicyModel> _filterPolicies(List<InsurancePolicyModel> all) {
    if (_selectedFilter.startsWith('Health')) {
      return all.where((p) => p.policyType == PolicyType.health).toList();
    } else if (_selectedFilter.startsWith('Term Life')) {
      return all.where((p) => p.policyType == PolicyType.termLife).toList();
    } else if (_selectedFilter.startsWith('Automobile')) {
      return all.where((p) => p.policyType == PolicyType.auto).toList();
    }
    return all;
  }
}
