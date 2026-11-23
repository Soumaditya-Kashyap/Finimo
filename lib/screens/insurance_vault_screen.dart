import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../models/insurance_policy_model.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../services/insurance_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/insurance_policy_card.dart';
import '../widgets/insurance_vault_hero_card.dart';
import 'user_profile_screen.dart';

class InsuranceVaultScreen extends StatefulWidget {
  final HomeRepository repository;
  final InsuranceRepository? insuranceRepository;
  final FamilyRepository? familyRepository;

  const InsuranceVaultScreen({
    super.key,
    required this.repository,
    this.insuranceRepository,
    this.familyRepository,
  });

  @override
  State<InsuranceVaultScreen> createState() => _InsuranceVaultScreenState();
}

class _InsuranceVaultScreenState extends State<InsuranceVaultScreen> {
  late final InsuranceRepository _insuranceRepo;
  late final FamilyRepository _familyRepo;

  InsuranceVaultOverview? _lastLoadedOverview;
  bool _isLoading = true;
  String? _errorMessage;
  List<FamilyMember> _familyMembers = [];

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _insuranceRepo = widget.insuranceRepository ?? HttpInsuranceRepository();
    _familyRepo = widget.familyRepository ?? HttpFamilyRepository();
    _loadFamilyMembers();
    _loadData();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final members = await _familyRepo.getFamilyMembers();
      if (mounted) {
        setState(() {
          _familyMembers = members;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent && _lastLoadedOverview == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final overview = await _insuranceRepo.getInsuranceOverview();
      if (mounted) {
        setState(() {
          _lastLoadedOverview = overview;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_lastLoadedOverview != null) {
          setState(() {
            _isLoading = false;
          });
          if (!silent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Connection issue. Showing cached policies.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.surface02,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  Future<void> _deletePolicy(InsurancePolicyModel policy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface01,
        title: Text(
          'Remove Policy?',
          style: AppTypography.headlineSm(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove "${policy.policyName}" from your family protection vault?',
          style: AppTypography.bodySm(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _insuranceRepo.deletePolicy(policy.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed ${policy.policyName}'),
              backgroundColor: AppColors.surface02,
            ),
          );
          _loadData(silent: true);
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete policy: $err'),
              backgroundColor: AppColors.dangerCoral,
            ),
          );
        }
      }
    }
  }

  void _showAddPolicySheet() {
    String? selectedMemberId =
        _familyMembers.isNotEmpty ? _familyMembers.first.id : null;
    String policyType = 'HEALTH';
    String premiumFrequency = 'ANNUAL';
    DateTime renewalDate = DateTime.now().add(const Duration(days: 365));

    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final sumAssuredController = TextEditingController();
    final premiumController = TextEditingController();

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasBase,
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REGISTER POLICY',
                          style: AppTypography.labelSm(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ).copyWith(letterSpacing: 1.0),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add Family Insurance',
                      style: AppTypography.headlineSm(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Insured Member
                    Text(
                      'INSURED FAMILY MEMBER',
                      style: AppTypography.labelSm(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    if (_familyMembers.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _familyMembers.map((m) {
                          final isSelected = selectedMemberId == m.id;
                          return ChoiceChip(
                            label: Text(m.name),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setSheetState(() => selectedMemberId = m.id);
                              }
                            },
                            selectedColor: AppColors.primaryFixed,
                            backgroundColor: AppColors.surface01,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.canvasBase
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'No family members found.',
                        style: AppTypography.bodySm(color: AppColors.textMuted),
                      ),

                    const SizedBox(height: 16),

                    // 2. Policy Type
                    Text(
                      'POLICY TYPE',
                      style: AppTypography.labelSm(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTypeChip('HEALTH', 'Health', policyType, (t) {
                          setSheetState(() => policyType = t);
                        }),
                        _buildTypeChip('TERM_LIFE', 'Term Life', policyType,
                            (t) {
                          setSheetState(() => policyType = t);
                        }),
                        _buildTypeChip('AUTO', 'Vehicle', policyType, (t) {
                          setSheetState(() => policyType = t);
                        }),
                        _buildTypeChip('OTHER', 'Asset/Other', policyType, (t) {
                          setSheetState(() => policyType = t);
                        }),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3. Policy Name
                    _buildInputField(
                      controller: nameController,
                      label: 'POLICY NAME',
                      hintText: 'e.g. Care Supreme, HDFC Click 2 Protect',
                    ),

                    const SizedBox(height: 14),

                    // 4. Policy Number (Optional)
                    _buildInputField(
                      controller: numberController,
                      label: 'POLICY NUMBER (OPTIONAL)',
                      hintText: 'e.g. POL-9823412',
                    ),

                    const SizedBox(height: 14),

                    // 5. Sum Assured & Premium
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: sumAssuredController,
                            label: 'SUM ASSURED (₹)',
                            hintText: 'e.g. 10000000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: premiumController,
                            label: 'PREMIUM (₹)',
                            hintText: 'e.g. 24000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 6. Frequency & Renewal Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAYMENT CYCLE',
                                style: AppTypography.labelSm(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(fontSize: 10),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface01,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.ghostBorder,
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: premiumFrequency,
                                    dropdownColor: AppColors.surface01,
                                    isExpanded: true,
                                    style: AppTypography.bodySm(
                                      color: AppColors.textPrimary,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'ANNUAL',
                                        child: Text('Annual'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'MONTHLY',
                                        child: Text('Monthly'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'QUARTERLY',
                                        child: Text('Quarterly'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setSheetState(
                                          () => premiumFrequency = val,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RENEWAL DUE DATE',
                                style: AppTypography.labelSm(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(fontSize: 10),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: renewalDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2035),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: AppColors.primaryFixed,
                                            onPrimary: AppColors.canvasBase,
                                            surface: AppColors.surface01,
                                            onSurface: AppColors.textPrimary,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setSheetState(() => renewalDate = picked);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface01,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.ghostBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${renewalDate.day}/${renewalDate.month}/${renewalDate.year}',
                                        style: AppTypography.bodySm(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final sum = double.tryParse(
                                        sumAssuredController.text.trim()) ??
                                    0.0;
                                final premium = double.tryParse(
                                        premiumController.text.trim()) ??
                                    0.0;

                                if (selectedMemberId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select an insured family member.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please enter a policy name.'),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => isSubmitting = true);

                                final nav = Navigator.of(ctx);
                                final messenger = ScaffoldMessenger.of(context);

                                final req = CreateInsuranceRequest(
                                  insuredMemberId: selectedMemberId!,
                                  policyName: name,
                                  policyType: policyType,
                                  policyNumber: numberController.text.trim(),
                                  sumAssured: sum,
                                  premiumAmount: premium,
                                  premiumFrequency: premiumFrequency,
                                  renewalDueDate: renewalDate
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                                  status: 'ACTIVE',
                                );

                                try {
                                  await _insuranceRepo.createPolicy(req);
                                  if (!mounted) return;
                                  nav.pop();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Policy "$name" registered successfully!',
                                      ),
                                      backgroundColor: AppColors.surface02,
                                    ),
                                  );
                                  _loadData(silent: true);
                                } catch (err) {
                                  setSheetState(() => isSubmitting = false);
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $err'),
                                      backgroundColor: AppColors.dangerCoral,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryFixed,
                          foregroundColor: AppColors.canvasBase,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.canvasBase,
                                ),
                              )
                            : const Text(
                                'Save & Register Policy',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
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

  Widget _buildTypeChip(
    String type,
    String label,
    String currentSelected,
    Function(String) onSelect,
  ) {
    final isSelected = currentSelected == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) onSelect(type);
      },
      selectedColor: AppColors.tertiaryFixed,
      backgroundColor: AppColors.surface01,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.canvasBase : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSm(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.bodySm(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodySm(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface01,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.ghostBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryFixed),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopHeader(context),

            // Sub Header with + Add Policy Button
            _buildSubHeader(context),

            // Content
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _lastLoadedOverview == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryFixed),
      );
    }

    if (_errorMessage != null && _lastLoadedOverview == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.dangerCoral,
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading insurance vault',
                style: AppTypography.headlineSm(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: AppTypography.bodySm(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loadData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.canvasBase,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final overview = _lastLoadedOverview!;
    final filteredPolicies = _filterPolicies(overview.policies);

    return RefreshIndicator(
      onRefresh: () => _loadData(silent: true),
      color: AppColors.primaryFixed,
      backgroundColor: AppColors.surface01,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card: Total Family Umbrella Cover
            InsuranceVaultHeroCard(overview: overview),

            const SizedBox(height: 18),

            // Dynamic Filter Carousel
            _buildFilterRow(overview.policies),

            const SizedBox(height: 20),

            // Section Title: Active Policies & Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registered Policies',
                  style: AppTypography.headlineSm(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 17),
                ),
                Text(
                  '${filteredPolicies.length} POLICIES',
                  style: AppTypography.caption(
                    color: AppColors.primaryFixed,
                  ).copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (filteredPolicies.isEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                decoration: BoxDecoration(
                  color: AppColors.surface01,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ghostBorder, width: 0.5),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.textMuted,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      overview.policies.isEmpty
                          ? 'No Insurance Policies Registered'
                          : 'No policies match this filter',
                      style: AppTypography.bodyLg(color: AppColors.textPrimary)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overview.policies.isEmpty
                          ? 'Keep your family protected by registering your health, term life, and vehicle policies.'
                          : 'Try selecting a different filter category above.',
                      style: AppTypography.bodySm(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    if (overview.policies.isEmpty) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddPolicySheet,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add First Policy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryFixed,
                          foregroundColor: AppColors.canvasBase,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
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
                    onDeleteTap: () => _deletePolicy(policy),
                  );
                },
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

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
                'INSURANCE',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ).copyWith(fontSize: 15, letterSpacing: 0.5),
              ),
            ],
          ),
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
    );
  }

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
                  const Text(
                    'FAMILY PROTECTION',
                    style: TextStyle(
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

          // + Add Policy Pill Button
          ElevatedButton.icon(
            onPressed: _showAddPolicySheet,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Policy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryFixed,
              foregroundColor: AppColors.canvasBase,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(List<InsurancePolicyModel> allPolicies) {
    final healthCount =
        allPolicies.where((p) => p.policyType == PolicyType.health).length;
    final termCount =
        allPolicies.where((p) => p.policyType == PolicyType.termLife).length;
    final autoCount =
        allPolicies.where((p) => p.policyType == PolicyType.auto).length;
    final otherCount =
        allPolicies.where((p) => p.policyType == PolicyType.other).length;

    final filters = [
      {'key': 'All', 'label': 'All (${allPolicies.length})'},
      {'key': 'Health', 'label': 'Health ($healthCount)'},
      {'key': 'Term Life', 'label': 'Term Life ($termCount)'},
      {'key': 'Vehicle', 'label': 'Vehicle ($autoCount)'},
      if (otherCount > 0)
        {'key': 'Asset', 'label': 'Asset ($otherCount)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final f in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = f['key']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedFilter == f['key']
                        ? AppColors.tertiaryFixed
                        : AppColors.surface01,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: _selectedFilter == f['key']
                          ? AppColors.tertiaryFixed
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                    boxShadow: _selectedFilter == f['key']
                        ? [
                            BoxShadow(
                              color: AppColors.tertiaryFixed
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: _selectedFilter == f['key']
                          ? Colors.black
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: _selectedFilter == f['key']
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

  List<InsurancePolicyModel> _filterPolicies(List<InsurancePolicyModel> all) {
    if (_selectedFilter == 'Health') {
      return all.where((p) => p.policyType == PolicyType.health).toList();
    } else if (_selectedFilter == 'Term Life') {
      return all.where((p) => p.policyType == PolicyType.termLife).toList();
    } else if (_selectedFilter == 'Vehicle') {
      return all.where((p) => p.policyType == PolicyType.auto).toList();
    } else if (_selectedFilter == 'Asset') {
      return all.where((p) => p.policyType == PolicyType.other).toList();
    }
    return all;
  }
}
