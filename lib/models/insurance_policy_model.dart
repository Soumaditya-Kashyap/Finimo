import '../utils/currency_formatter.dart';

enum PolicyType { termLife, health, auto, other }

enum PolicyStatus { active, pendingRenewal, lapsed }

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  int get daysUntilRenewal {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      renewalDueDate.year,
      renewalDueDate.month,
      renewalDueDate.day,
    );
    return due.difference(today).inDays;
  }

  static PolicyType parseType(String? t) {
    switch (t?.toUpperCase()) {
      case 'HEALTH':
        return PolicyType.health;
      case 'AUTO':
      case 'MOTOR':
      case 'MOTOR_ASSET':
        return PolicyType.auto;
      case 'OTHER':
        return PolicyType.other;
      case 'TERM_LIFE':
      default:
        return PolicyType.termLife;
    }
  }

  static String toApiType(PolicyType type) {
    switch (type) {
      case PolicyType.health:
        return 'HEALTH';
      case PolicyType.auto:
        return 'AUTO';
      case PolicyType.other:
        return 'OTHER';
      case PolicyType.termLife:
        return 'TERM_LIFE';
    }
  }

  static PolicyStatus parseStatus(String? s) {
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

  static String toApiStatus(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.pendingRenewal:
        return 'PENDING_RENEWAL';
      case PolicyStatus.lapsed:
        return 'LAPSED';
      case PolicyStatus.active:
        return 'ACTIVE';
    }
  }

  static String formatSumAssured(double amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      final formatted = cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 2);
      return '₹$formatted Cr';
    } else if (amount >= 100000) {
      final l = amount / 100000;
      final formatted = l.toStringAsFixed(l.truncateToDouble() == l ? 0 : 1);
      return '₹$formatted L';
    } else {
      return CurrencyFormatter.formatInr(amount);
    }
  }

  factory InsurancePolicyModel.fromApiResponse(
    Map<String, dynamic> json, {
    String memberName = 'Family Member',
  }) {
    return InsurancePolicyModel(
      id: json['id']?.toString() ?? '',
      familyId: json['family_id']?.toString() ?? '',
      insuredMemberId: json['insured_member_id']?.toString() ?? '',
      insuredMemberName: json['insured_member_name']?.toString() ?? memberName,
      policyName: json['policy_name']?.toString() ?? 'Insurance Policy',
      policyType: parseType(json['policy_type']?.toString()),
      policyNumber: json['policy_number']?.toString(),
      sumAssured: _parseDouble(json['sum_assured']),
      premiumAmount: _parseDouble(json['premium_amount']),
      premiumFrequency: json['premium_frequency']?.toString().toUpperCase() ?? 'ANNUAL',
      renewalDueDate: json['renewal_due_date'] != null
          ? DateTime.tryParse(json['renewal_due_date'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      status: parseStatus(json['status']?.toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  factory InsurancePolicyModel.fromJson(Map<String, dynamic> json) =>
      InsurancePolicyModel.fromApiResponse(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'insured_member_id': insuredMemberId,
      'insured_member_name': insuredMemberName,
      'policy_name': policyName,
      'policy_type': toApiType(policyType),
      'policy_number': policyNumber,
      'sum_assured': sumAssured.toString(),
      'premium_amount': premiumAmount.toString(),
      'premium_frequency': premiumFrequency,
      'renewal_due_date': renewalDueDate.toIso8601String().split('T').first,
      'status': toApiStatus(status),
    };
  }
}

class CreateInsuranceRequest {
  final String insuredMemberId;
  final String policyName;
  final String policyType; // 'TERM_LIFE', 'HEALTH', 'AUTO', 'OTHER'
  final String? policyNumber;
  final double sumAssured;
  final double premiumAmount;
  final String premiumFrequency; // 'ANNUAL', 'MONTHLY', 'QUARTERLY'
  final String renewalDueDate; // 'YYYY-MM-DD'
  final String status; // 'ACTIVE', 'LAPSED', 'PENDING_RENEWAL'

  CreateInsuranceRequest({
    required this.insuredMemberId,
    required this.policyName,
    required this.policyType,
    this.policyNumber,
    required this.sumAssured,
    required this.premiumAmount,
    this.premiumFrequency = 'ANNUAL',
    required this.renewalDueDate,
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'insured_member_id': insuredMemberId,
      'policy_name': policyName,
      'policy_type': policyType,
      'sum_assured': sumAssured,
      'premium_amount': premiumAmount,
      'premium_frequency': premiumFrequency,
      'renewal_due_date': renewalDueDate,
      'status': status,
    };
    if (policyNumber != null && policyNumber!.trim().isNotEmpty) {
      map['policy_number'] = policyNumber!.trim();
    }
    return map;
  }
}

class MemberInsuranceGroup {
  final String memberId;
  final String memberName;
  final double totalSumAssured;
  final List<InsurancePolicyModel> policies;

  const MemberInsuranceGroup({
    required this.memberId,
    required this.memberName,
    required this.totalSumAssured,
    required this.policies,
  });

  factory MemberInsuranceGroup.fromApiResponse(Map<String, dynamic> json) {
    final memId = json['member_id']?.toString() ?? '';
    final name = json['member_name']?.toString() ?? 'Family Member';
    final total = _parseDouble(json['total_sum_assured']);

    final rawPolicies = json['policies'] as List<dynamic>? ?? [];
    final policiesList = rawPolicies
        .whereType<Map<String, dynamic>>()
        .map((p) => InsurancePolicyModel.fromApiResponse(p, memberName: name))
        .toList();

    return MemberInsuranceGroup(
      memberId: memId,
      memberName: name,
      totalSumAssured: total,
      policies: policiesList,
    );
  }
}

class InsuranceVaultOverview {
  final double totalSumAssuredUmbrella;
  final String formattedUmbrellaText;
  final int coveredFamilyMembersCount;
  final double annualCostTotal;
  final double monthlyCostEquivalent;
  final String nextCycleText;
  final String nextCycleStatus;
  final List<InsurancePolicyModel> policies;
  final List<MemberInsuranceGroup> memberGroups;

  const InsuranceVaultOverview({
    required this.totalSumAssuredUmbrella,
    required this.formattedUmbrellaText,
    required this.coveredFamilyMembersCount,
    required this.annualCostTotal,
    required this.monthlyCostEquivalent,
    required this.nextCycleText,
    required this.nextCycleStatus,
    required this.policies,
    this.memberGroups = const [],
  });

  factory InsuranceVaultOverview.fromApiResponse(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    final memberGroups = <MemberInsuranceGroup>[];
    final allPolicies = <InsurancePolicyModel>[];

    for (final m in rawMembers) {
      if (m is Map<String, dynamic>) {
        final group = MemberInsuranceGroup.fromApiResponse(m);
        memberGroups.add(group);
        allPolicies.addAll(group.policies);
      }
    }

    final total = _parseDouble(json['total_sum_assured_umbrella']);

    final coveredMembers = memberGroups.where((g) => g.policies.isNotEmpty).length;

    // Calculate annual cost accurately from all policies
    double annualCost = 0.0;
    for (final p in allPolicies) {
      if (p.premiumFrequency == 'MONTHLY') {
        annualCost += (p.premiumAmount * 12);
      } else if (p.premiumFrequency == 'QUARTERLY') {
        annualCost += (p.premiumAmount * 4);
      } else {
        annualCost += p.premiumAmount;
      }
    }

    final monthlyEquivalent = annualCost / 12.0;

    // Find nearest upcoming renewal date
    String nextCycle = 'None';
    String nextStatus = 'All Active';
    if (allPolicies.isNotEmpty) {
      final sortedByDate = List<InsurancePolicyModel>.from(allPolicies)
        ..sort((a, b) => a.renewalDueDate.compareTo(b.renewalDueDate));
      final nextPolicy = sortedByDate.firstWhere(
        (p) => p.daysUntilRenewal >= 0,
        orElse: () => sortedByDate.first,
      );

      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final monthStr = months[nextPolicy.renewalDueDate.month - 1];
      final yearStr = (nextPolicy.renewalDueDate.year % 100).toString();
      nextCycle = "$monthStr '$yearStr";

      if (nextPolicy.daysUntilRenewal <= 30) {
        nextStatus = 'Expiring in ${nextPolicy.daysUntilRenewal}d';
      } else {
        nextStatus = 'Active Pacing';
      }
    }

    return InsuranceVaultOverview(
      totalSumAssuredUmbrella: total,
      formattedUmbrellaText: InsurancePolicyModel.formatSumAssured(total),
      coveredFamilyMembersCount: coveredMembers,
      annualCostTotal: annualCost,
      monthlyCostEquivalent: monthlyEquivalent,
      nextCycleText: nextCycle,
      nextCycleStatus: nextStatus,
      policies: allPolicies,
      memberGroups: memberGroups,
    );
  }

  factory InsuranceVaultOverview.fromJson(Map<String, dynamic> json) =>
      InsuranceVaultOverview.fromApiResponse(json);

  Map<String, dynamic> toJson() {
    return {
      'total_sum_assured_umbrella': totalSumAssuredUmbrella.toString(),
      'members': memberGroups.map((g) => {
        'member_id': g.memberId,
        'member_name': g.memberName,
        'total_sum_assured': g.totalSumAssured.toString(),
        'policies': g.policies.map((p) => p.toJson()).toList(),
      }).toList(),
    };
  }
}
