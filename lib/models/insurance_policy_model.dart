enum PolicyType { termLife, health, auto, other }

enum PolicyStatus { active, pendingRenewal, lapsed }

class InsurancePolicyModel {
  final String id;
  final String familyId;
  final String insuredMemberId;
  final String insuredMemberName;
  final String policyName;
  final PolicyType policyType;
  final String? policyNumber;
  final double sumAssured;
  final double premiumAmount;
  final String premiumFrequency; // 'ANNUAL' | 'MONTHLY' | 'QUARTERLY'
  final DateTime renewalDueDate;
  final PolicyStatus status;
  final String? nomineeName;
  final String? subDetailText;
  final bool isActionRequired;
  final int? expiryDaysLeft;
  final double? sinkingFundBalance;

  const InsurancePolicyModel({
    required this.id,
    required this.familyId,
    required this.insuredMemberId,
    required this.insuredMemberName,
    required this.policyName,
    required this.policyType,
    this.policyNumber,
    required this.sumAssured,
    required this.premiumAmount,
    this.premiumFrequency = 'ANNUAL',
    required this.renewalDueDate,
    this.status = PolicyStatus.active,
    this.nomineeName,
    this.subDetailText,
    this.isActionRequired = false,
    this.expiryDaysLeft,
    this.sinkingFundBalance,
  });

  factory InsurancePolicyModel.fromJson(Map<String, dynamic> json) {
    PolicyType parseType(String? t) {
      switch (t?.toUpperCase()) {
        case 'HEALTH':
          return PolicyType.health;
        case 'AUTO':
        case 'MOTOR':
        case 'MOTOR_ASSET':
          return PolicyType.auto;
        case 'TERM_LIFE':
        default:
          return PolicyType.termLife;
      }
    }

    PolicyStatus parseStatus(String? s) {
      switch (s?.toUpperCase()) {
        case 'PENDING_RENEWAL':
          return PolicyStatus.pendingRenewal;
        case 'LAPSED':
          return PolicyStatus.lapsed;
        case 'ACTIVE':
        default:
          return PolicyStatus.active;
      }
    }

    return InsurancePolicyModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String? ?? '',
      insuredMemberId: json['insured_member_id'] as String? ?? '',
      insuredMemberName: json['insured_member_name'] as String? ?? 'Arpa',
      policyName: json['policy_name'] as String,
      policyType: parseType(json['policy_type'] as String?),
      policyNumber: json['policy_number'] as String?,
      sumAssured: double.tryParse(json['sum_assured']?.toString() ?? '0') ?? 0.0,
      premiumAmount:
          double.tryParse(json['premium_amount']?.toString() ?? '0') ?? 0.0,
      premiumFrequency: json['premium_frequency'] as String? ?? 'ANNUAL',
      renewalDueDate: json['renewal_due_date'] != null
          ? DateTime.tryParse(json['renewal_due_date'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      status: parseStatus(json['status'] as String?),
      nomineeName: json['nominee_name'] as String?,
      subDetailText: json['sub_detail_text'] as String?,
      isActionRequired: json['is_action_required'] as bool? ?? false,
      expiryDaysLeft: json['expiry_days_left'] as int?,
      sinkingFundBalance: json['sinking_fund_balance'] != null
          ? double.tryParse(json['sinking_fund_balance'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'insured_member_id': insuredMemberId,
      'insured_member_name': insuredMemberName,
      'policy_name': policyName,
      'policy_type': policyType.name,
      'policy_number': policyNumber,
      'sum_assured': sumAssured.toString(),
      'premium_amount': premiumAmount.toString(),
      'premium_frequency': premiumFrequency,
      'renewal_due_date': renewalDueDate.toIso8601String().split('T').first,
      'status': status.name,
      'nominee_name': nomineeName,
      'sub_detail_text': subDetailText,
      'is_action_required': isActionRequired,
      'expiry_days_left': expiryDaysLeft,
      'sinking_fund_balance': sinkingFundBalance,
    };
  }
}

class InsuranceVaultOverview {
  final double totalSumAssuredUmbrella; // e.g. 1.25 Cr (12500000)
  final String formattedUmbrellaText; // "₹1.25 Cr"
  final int coveredFamilyMembersCount; // 3
  final double annualCostTotal; // 34500
  final double monthlyCostEquivalent; // 2875
  final String nextCycleText; // "Nov '26"
  final String nextCycleStatus; // "Auto-Funded"
  final int activeClaimsCount; // 0
  final List<InsurancePolicyModel> policies;

  const InsuranceVaultOverview({
    required this.totalSumAssuredUmbrella,
    required this.formattedUmbrellaText,
    required this.coveredFamilyMembersCount,
    required this.annualCostTotal,
    required this.monthlyCostEquivalent,
    required this.nextCycleText,
    required this.nextCycleStatus,
    required this.activeClaimsCount,
    required this.policies,
  });

  factory InsuranceVaultOverview.fromJson(Map<String, dynamic> json) {
    final list = (json['members'] as List<dynamic>?)
            ?.expand((m) => (m['policies'] as List<dynamic>? ?? []))
            .map((p) => InsurancePolicyModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    final total = double.tryParse(
            json['total_sum_assured_umbrella']?.toString() ?? '12500000') ??
        12500000.0;

    return InsuranceVaultOverview(
      totalSumAssuredUmbrella: total,
      formattedUmbrellaText: json['formatted_umbrella_text'] as String? ?? '₹1.25 Cr',
      coveredFamilyMembersCount: json['covered_members_count'] as int? ?? 3,
      annualCostTotal:
          double.tryParse(json['annual_cost_total']?.toString() ?? '34500') ??
              34500.0,
      monthlyCostEquivalent:
          double.tryParse(json['monthly_cost_equivalent']?.toString() ?? '2875') ??
              2875.0,
      nextCycleText: json['next_cycle_text'] as String? ?? "Nov '26",
      nextCycleStatus: json['next_cycle_status'] as String? ?? 'Auto-Funded',
      activeClaimsCount: json['active_claims_count'] as int? ?? 0,
      policies: list,
    );
  }
}
