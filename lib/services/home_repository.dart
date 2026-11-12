import '../models/family_member.dart';
import '../models/home_dashboard_data.dart';
import '../models/conjoined_event_summary.dart';
import '../models/transaction_item.dart';

import '../models/ledger_transaction.dart';
import '../models/activity_summary.dart';
import '../models/targets_dashboard_data.dart';
import '../models/monthly_limit_item.dart';
import '../models/sinking_fund_goal.dart';
import '../models/deep_dive_models.dart';
import '../models/user_profile_data.dart';
import '../models/conjoined_event_detail.dart';
import '../models/insurance_policy_model.dart';
import '../core/token_storage.dart';
import 'package:flutter/material.dart';

abstract class HomeRepository {
  Future<List<FamilyMember>> getFamilyMembers();
  Future<HomeDashboardData> getDashboardMetrics();
  Future<ConjoinedEventSummary> getActiveConjoinedEvent();
  Future<List<TransactionItem>> getRecentFlows();
  Future<ActivitySummary> getActivitySummary();
  Future<List<LedgerTransaction>> getLedgerTransactions();
  Future<TargetsDashboardData> getTargetsDashboardData();
  Future<List<MonthlyLimitItem>> getActiveMonthlyLimits();
  Future<List<SinkingFundGoal>> getSinkingFundGoals();
  Future<DeepDiveSummaryData> getDeepDiveSummaryData();
  Future<UserProfileData> getUserProfileData();
  Future<ConjoinedEventDetail> getConjoinedEventDetail(String eventId);
  Future<InsuranceVaultOverview> getInsuranceVaultOverview();
}

/// Mock implementation returning exact data points shown in screenshot & Phase 1 spec.
/// Swapping to live API requires changing only this implementation.
class MockHomeRepository implements HomeRepository {
  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    // TODO: Replace mock data with real API call to GET /api/v1/family/members
    return const [
      FamilyMember(
        id: 'm1_arpa',
        name: 'Arpa',
        initial: 'A',
        relationType: MemberRelation.admin,
      ),
      FamilyMember(
        id: 'm2_chandrani',
        name: 'Chandrani',
        initial: 'C',
        relationType: MemberRelation.spouse,
      ),
      FamilyMember(
        id: 'm3_aryahi',
        name: 'Aryahi',
        initial: 'R',
        relationType: MemberRelation.child,
      ),
    ];
  }

  @override
  Future<HomeDashboardData> getDashboardMetrics() async {
    // TODO: Replace mock data with real API call to GET /api/v1/insights/summary
    return const HomeDashboardData(
      consolidatedLiquidity: 216949.00,
      jointAccountsCount: 4,
      monthlyInflow: 182500.00,
      monthlySpent: 58281.00,
      dailySafeBurn: 420.00,
      livePingSeconds: '04S',
    );
  }

  @override
  Future<ConjoinedEventSummary> getActiveConjoinedEvent() async {
    // TODO: Replace mock data with real API call to GET /api/v1/events
    return const ConjoinedEventSummary(
      id: 'ev_pujo',
      title: 'Durga Puja 2026',
      budgetCap: 10000.00,
      totalSpent: 8672.00,
      remainingBudget: 1328.00,
      percentageUsed: 86.7,
      contributingMembersCount: 3,
    );
  }

  @override
  Future<List<TransactionItem>> getRecentFlows() async {
    // TODO: Replace mock data with real API call to GET /api/v1/transactions
    return const [
      TransactionItem(
        id: 'tx_1',
        title: 'iPhone EMI',
        subtitle: 'HDFC SmartPay • 10:42 AM',
        amount: 1691.00,
        type: TransactionType.expense,
        attributionName: 'ARPA',
        attributionTagColor: 'purple',
        iconKey: 'smartphone',
      ),
      TransactionItem(
        id: 'tx_2',
        title: 'Groceries',
        subtitle: 'Blinkit Basket • Yesterday',
        amount: 965.00,
        type: TransactionType.expense,
        attributionName: 'FAMILY',
        attributionTagColor: 'lime',
        iconKey: 'shopping_bag',
      ),
      TransactionItem(
        id: 'tx_3',
        title: 'Pediatric Visit',
        subtitle: 'Apollo Clinic • 23 Oct',
        amount: 500.00,
        type: TransactionType.expense,
        attributionName: 'ARYAHI',
        attributionTagColor: 'cyan',
        iconKey: 'stethoscope',
      ),
    ];
  }

  @override
  Future<ActivitySummary> getActivitySummary() async {
    // TODO: Replace with live API call to GET /api/v1/insights/summary
    return const ActivitySummary(
      totalCount: 42,
      netAmount: 124219.00,
      outflowAmount: 58281.00,
      inflowAmount: 182500.00,
    );
  }

  @override
  Future<List<LedgerTransaction>> getLedgerTransactions() async {
    // TODO: Replace with live API call to GET /api/v1/transactions
    return const [
      // Today 1: FabIndia Garments
      LedgerTransaction(
        id: 'lt_1',
        title: 'FabIndia Garments',
        categoryName: 'Dining & Garments',
        amount: 4025.00,
        isExpense: true,
        timeString: '18:42',
        dateSection: 'Today',
        payerInitial: 'C',
        payerName: 'Chandrani',
        beneficiaryName: 'Chandrani',
        badgeText: 'Pujo 2026',
        badgeColor: Color(0xFFE9B3FF),
        icon: Icons.shopping_bag_outlined,
      ),
      // Today 2: Apollo Pharmacy
      LedgerTransaction(
        id: 'lt_2',
        title: 'Apollo Pharmacy',
        categoryName: 'Medical',
        amount: 500.00,
        isExpense: true,
        timeString: '14:15',
        dateSection: 'Today',
        payerInitial: 'A',
        payerName: 'Arpa',
        beneficiaryName: 'Aryahi',
        badgeText: 'Child Care',
        badgeColor: Color(0xFF63F7FF),
        icon: Icons.medication_outlined,
      ),
      // Yesterday 1: Salary Credit
      LedgerTransaction(
        id: 'lt_3',
        title: 'Salary Credit (Tech Corp)',
        categoryName: 'Income',
        amount: 182500.00,
        isExpense: false,
        timeString: '09:00',
        dateSection: 'Yesterday',
        payerInitial: 'A',
        payerName: 'Arpa',
        beneficiaryName: 'Household Pool',
        badgeText: 'Primary Inflow',
        badgeColor: Color(0xFF8E8E93),
        icon: Icons.account_balance_outlined,
      ),
      // Yesterday 2: iPhone 15 Pro EMI
      LedgerTransaction(
        id: 'lt_4',
        title: 'iPhone 15 Pro EMI',
        categoryName: 'EMIs',
        amount: 1691.00,
        isExpense: true,
        timeString: '11:30',
        dateSection: 'Yesterday',
        payerInitial: 'A',
        payerName: 'Arpa',
        beneficiaryName: 'Arpa',
        badgeText: 'Auto-Debit',
        badgeColor: Color(0xFF8E8E93),
        icon: Icons.phone_android_rounded,
      ),
      // Yesterday 3: Star Health Premium
      LedgerTransaction(
        id: 'lt_5',
        title: 'Star Health Premium',
        categoryName: 'Insurance',
        amount: 1500.00,
        isExpense: true,
        timeString: '08:15',
        dateSection: 'Yesterday',
        payerInitial: 'A',
        payerName: 'Arpa',
        beneficiaryName: 'Entire Family',
        icon: Icons.health_and_safety_outlined,
        isMultiBeneficiary: true,
      ),
    ];
  }

  @override
  Future<TargetsDashboardData> getTargetsDashboardData() async {
    // TODO: Replace with live API call to GET /api/v1/targets & /insights/summary
    return const TargetsDashboardData(
      budgetRemainingPct: 74.0,
      budgetRemainingAmount: 42120.00,
      safeCapAmount: 58000.00,
      daysLeft: 18,
      pacingProgress: 0.82,
      runwayProgress: 0.74,
    );
  }

  @override
  Future<List<MonthlyLimitItem>> getActiveMonthlyLimits() async {
    // TODO: Replace with live API call to GET /api/v1/targets
    return const [
      MonthlyLimitItem(
        id: 'lim_1',
        title: 'Household & Utilities',
        limitCap: 20000.00,
        currentSpent: 14200.00,
        percentageUsed: 71.0,
        statusText: '₹5,800 buffer',
        footerStatus: 'Spending within limit',
        accentColor: Color(0xFFC3F400), // Electric Lime
        icon: Icons.roofing_outlined,
      ),
      MonthlyLimitItem(
        id: 'lim_2',
        title: 'Discretionary & Dining',
        limitCap: 5000.00,
        currentSpent: 3850.00,
        percentageUsed: 77.0,
        statusText: '₹1,150 left',
        footerStatus: 'Spending quickly',
        accentColor: Color(0xFFFF453A), // Danger Coral
        icon: Icons.restaurant_outlined,
        isWarning: true,
      ),
      MonthlyLimitItem(
        id: 'lim_3',
        title: 'Aryahi Pediatric & Schooling',
        limitCap: 6000.00,
        currentSpent: 2500.00,
        percentageUsed: 41.0,
        statusText: 'On track',
        footerStatus: '₹3,500 cushion',
        accentColor: Color(0xFF63F7FF), // Cyber Cyan
        icon: Icons.school_outlined,
      ),
    ];
  }

  @override
  Future<List<SinkingFundGoal>> getSinkingFundGoals() async {
    // TODO: Replace with live API call to GET /api/v1/events
    return const [
      SinkingFundGoal(
        id: 'sf_1',
        title: 'Durga Puja 2026',
        currentAmount: 8672.00,
        targetGoal: 10000.00,
        percentage: 86.7,
        neededText: '₹1,328 needed',
        paceStatus: 'On pace for Sep 2026',
        memberInitials: ['P', 'A'],
        isSecondaryPurple: true,
      ),
      SinkingFundGoal(
        id: 'sf_2',
        title: 'Japan Trip 2027',
        currentAmount: 45000.00,
        targetGoal: 250000.00,
        percentage: 18.0,
        neededText: '₹2,05,000 remaining',
        paceStatus: 'Auto-debit ₹8,500/mo',
        memberInitials: ['F'],
        isSecondaryPurple: false,
      ),
    ];
  }

  @override
  Future<DeepDiveSummaryData> getDeepDiveSummaryData() async {
    // TODO: Replace with live API call to GET /api/v1/insights/summary
    return const DeepDiveSummaryData(
      totalOutflow: 58281.00,
      statusLabel: 'Under Budget',
      dailyPace: 1879.00,
      daysMonitored: 31,
      categories: [
        InsightCategoryBurn(
          categoryName: 'Household & Utilities',
          amount: 19815.00,
          percentage: 34.0,
          deltaVsLastMonth: '+4.2% vs Sep',
          color: Color(0xFFC3F400), // Electric Lime
          icon: Icons.roofing_outlined,
        ),
        InsightCategoryBurn(
          categoryName: 'Fixed EMIs & Debt',
          amount: 18067.00,
          percentage: 31.0,
          deltaVsLastMonth: 'Locked schedule',
          color: Color(0xFFE9B3FF), // Neon Purple
          icon: Icons.payments_outlined,
        ),
        InsightCategoryBurn(
          categoryName: 'Festival & Festive Gifts',
          amount: 8742.00,
          percentage: 15.0,
          deltaVsLastMonth: 'Seasonal spike',
          color: Color(0xFF63F7FF), // Cyber Cyan
          icon: Icons.celebration_outlined,
        ),
        InsightCategoryBurn(
          categoryName: 'Food & Gourmet Dining',
          amount: 6993.00,
          percentage: 12.0,
          deltaVsLastMonth: '-8.1% vs Sep',
          color: Color(0xFFA6CF00), // Lime Dim
          icon: Icons.restaurant_outlined,
        ),
        InsightCategoryBurn(
          categoryName: 'Medical & Pharmacy',
          amount: 4664.00,
          percentage: 8.0,
          deltaVsLastMonth: 'Routine checkups',
          color: Color(0xFFFF453A), // Coral Red
          icon: Icons.medical_services_outlined,
        ),
      ],
      members: [
        InsightMemberBurn(
          memberId: 'm1_arpa',
          name: 'Arpa',
          role: 'Admin • Primary Earner',
          initial: 'A',
          totalPaid: 26226.00,
          totalBenefited: 20000.00,
          percentageOfTotal: 45.0,
          targetCap: 36500.00,
          bufferLeft: 10274.00,
          accentColor: Color(0xFFC3F400), // Electric Lime
        ),
        InsightMemberBurn(
          memberId: 'm2_chandrani',
          name: 'Chandrani',
          role: 'Co-Budgeter',
          initial: 'C',
          totalPaid: 20398.00,
          totalBenefited: 9025.00,
          percentageOfTotal: 35.0,
          targetCap: 25000.00,
          bufferLeft: 4602.00,
          accentColor: Color(0xFFE9B3FF), // Neon Purple
        ),
        InsightMemberBurn(
          memberId: 'm3_aryahi',
          name: 'Aryahi',
          role: 'Dependent Minor',
          initial: 'A',
          totalPaid: 11657.00,
          totalBenefited: 5500.00,
          percentageOfTotal: 20.0,
          targetCap: 12500.00,
          bufferLeft: 843.00,
          accentColor: Color(0xFF63F7FF), // Cyber Cyan
        ),
      ],
    );
  }

  @override
  Future<UserProfileData> getUserProfileData() async {
    try {
      final cached = await TokenStorage().getCachedUserProfile();
      if (cached != null) {
        return UserProfileData.fromJson(cached);
      }
    } catch (_) {}
    return const UserProfileData(
      fullName: 'Arpa Roy',
      email: 'arpa.roy@gmail.com',
      initials: 'AR',
      roleBadge: 'ADMIN / OWNER',
      isVerified: true,
      finimoId: '#8841',
      syncState: 'Active',
      sessionNode: 'Mobile App',
      familyEntityName: 'Roy Family',
      localeAndBasis: 'INR (₹) · Asia/Kolkata',
      accessScope: '1 Member',
      accessScopeBadge: 'Primary Admin',
      biometricSecurityEnabled: true,
      appVersion: 'FINIMO v1.0.0',
      appPhase: '(Phase 1 MVP)',
    );
  }

  @override
  Future<ConjoinedEventDetail> getConjoinedEventDetail(String eventId) async {
    // TODO: Replace mock data with real API call to GET /api/v1/events/:id or GET /api/v1/insights/summary
    return const ConjoinedEventDetail(
      id: 'event_durga_puja_2026',
      eventTitle: 'Durga Puja 2026',
      poolTag: 'EVENT BUDGET',
      poolSubtype: 'SHARED OCCASION',
      totalSunkVolume: 8672.00,
      budgetCap: 10000.00,
      spentPercentage: 86.7,
      remainingBuffer: 1328.00,
      activeMembersCount: 3,
      memberInitials: ['C', 'A', 'H'],
      avgDailyBurn: 1445.00,
      memberSplits: [
        EventMemberEquity(
          memberId: 'm2_chandrani',
          name: 'Chandrani',
          initial: 'C',
          amount: 4025.00,
          ratioPercentage: 46.4,
          accentColorValue: 0xFFBF5AF2, // Neon Purple
        ),
        EventMemberEquity(
          memberId: 'm1_arpa',
          name: 'Arpa',
          initial: 'A',
          amount: 2348.00,
          ratioPercentage: 27.1,
          accentColorValue: 0xFF00F5FF, // Cyber Cyan
        ),
        EventMemberEquity(
          memberId: 'm_family',
          name: 'Family',
          initial: 'H',
          amount: 2299.00,
          ratioPercentage: 26.5,
          accentColorValue: 0xFFCCFF00, // Electric Lime
        ),
      ],
      ledgerRecords: [
        EventLedgerRecord(
          id: 'rec_fabindia',
          title: 'FabIndia Garments',
          dateString: '08 Oct',
          categoryTag: 'ETHNIC WEAR',
          amount: 4025.00,
          paidByOrRecipient: 'Chandrani',
          paidByInitial: 'C',
          paidByColorValue: 0xFFBF5AF2,
          categoryIconCode: 0xe1af, // checkroom / clothing
        ),
        EventLedgerRecord(
          id: 'rec_bhog',
          title: 'Bhog & Puja Items',
          dateString: '07 Oct',
          categoryTag: 'RITUALS',
          amount: 2299.00,
          paidByOrRecipient: 'Household',
          paidByInitial: 'H',
          paidByColorValue: 0xFFCCFF00,
          categoryIconCode: 0xe5ef, // temple_hindu / mosque / castle
        ),
        EventLedgerRecord(
          id: 'rec_dinner',
          title: 'Restaurant Dinners',
          dateString: '06 Oct',
          categoryTag: 'DINING',
          amount: 1608.00,
          paidByOrRecipient: 'All Members',
          paidByInitial: '👥',
          paidByColorValue: 0xFF00F5FF,
          categoryIconCode: 0xe56c, // restaurant
        ),
        EventLedgerRecord(
          id: 'rec_discount',
          title: 'Discount Adjustment',
          dateString: 'Store Cashback',
          categoryTag: 'CASHBACK · Promotional',
          amount: 50.00,
          isCreditInflow: true,
          paidByOrRecipient: 'Store Cashback',
          paidByInitial: '✓',
          paidByColorValue: 0xFFCCFF00,
          categoryIconCode: 0xe3ab, // loyalty / local_offer
        ),
        EventLedgerRecord(
          id: 'rec_flowers',
          title: 'Durga Idol Flower Offerin...',
          dateString: '05 Oct',
          categoryTag: 'FLORALS',
          amount: 690.00,
          paidByOrRecipient: 'Arpa',
          paidByInitial: 'A',
          paidByColorValue: 0xFF00F5FF,
          categoryIconCode: 0xe8e6, // local_florist
        ),
      ],
    );
  }

  @override
  Future<InsuranceVaultOverview> getInsuranceVaultOverview() async {
    // TODO: Replace mock data with real API call to GET /api/v1/insurance
    return InsuranceVaultOverview(
      totalSumAssuredUmbrella: 12500000.0,
      formattedUmbrellaText: '₹1.25 Cr',
      coveredFamilyMembersCount: 3,
      annualCostTotal: 34500.0,
      monthlyCostEquivalent: 2875.0,
      nextCycleText: "Nov '26",
      nextCycleStatus: 'Auto-Funded',
      activeClaimsCount: 0,
      policies: [
        InsurancePolicyModel(
          id: 'pol_hdfc_term',
          familyId: 'fam_roy',
          insuredMemberId: 'm1_arpa',
          insuredMemberName: 'Arpa (Self)',
          policyName: 'HDFC Click 2 Protect 3D Plus',
          policyType: PolicyType.termLife,
          policyNumber: 'POL-981249',
          sumAssured: 10000000.0,
          premiumAmount: 18500.0,
          premiumFrequency: 'ANNUAL',
          renewalDueDate: DateTime(2026, 11, 18),
          status: PolicyStatus.active,
          nomineeName: 'Chandrani (Spouse)',
          subDetailText: 'Next: 18 Nov 2026 · ₹18,500/yr',
        ),
        InsurancePolicyModel(
          id: 'pol_care_supreme',
          familyId: 'fam_roy',
          insuredMemberId: 'm_family',
          insuredMemberName: '3 Covered',
          policyName: 'Care Supreme Comprehensive',
          policyType: PolicyType.health,
          policyNumber: 'CARE-449102',
          sumAssured: 2500000.0,
          premiumAmount: 16000.0,
          premiumFrequency: 'ANNUAL',
          renewalDueDate: DateTime(2027, 3, 15),
          status: PolicyStatus.active,
          nomineeName: 'Arpa, Chandrani & Aryahi',
          subDetailText: '14,000+ Cashless Hospitals · Zero Room Cap',
        ),
        InsurancePolicyModel(
          id: 'pol_tata_aig_creta',
          familyId: 'fam_roy',
          insuredMemberId: 'asset_creta',
          insuredMemberName: 'Creta · AS-01-EF-4291',
          policyName: 'Tata AIG Comprehensive Cover',
          policyType: PolicyType.auto,
          policyNumber: 'TATA-MOTOR-8812',
          sumAssured: 1450000.0,
          premiumAmount: 11420.0,
          premiumFrequency: 'ANNUAL',
          renewalDueDate: DateTime(2026, 11, 7),
          status: PolicyStatus.pendingRenewal,
          nomineeName: 'Zero Depreciation + B2B Engine Guard',
          subDetailText: 'Action Required · Expiry in 12 days',
          isActionRequired: true,
          expiryDaysLeft: 12,
          sinkingFundBalance: 12000.0,
        ),
      ],
    );
  }
}

