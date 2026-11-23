import '../models/insurance_policy_model.dart';
export 'http_insurance_repository.dart';

abstract class InsuranceRepository {
  Future<InsuranceVaultOverview> getInsuranceOverview();
  Future<InsurancePolicyModel> createPolicy(CreateInsuranceRequest request);
  Future<void> deletePolicy(String policyId);
  Future<InsurancePolicyModel> updatePolicy(
    String policyId,
    Map<String, dynamic> patch,
  );
}

class MockInsuranceRepository implements InsuranceRepository {
  final InsuranceVaultOverview? _overview;

  MockInsuranceRepository({InsuranceVaultOverview? initialOverview})
      : _overview = initialOverview;

  @override
  Future<InsuranceVaultOverview> getInsuranceOverview() async {
    return _overview ??
        InsuranceVaultOverview.fromApiResponse({
          'total_sum_assured_umbrella': '12500000.00',
          'members': [],
        });
  }

  @override
  Future<InsurancePolicyModel> createPolicy(
      CreateInsuranceRequest request) async {
    final policy = InsurancePolicyModel(
      id: 'mock_pol_${DateTime.now().millisecondsSinceEpoch}',
      familyId: 'mock_family_1',
      insuredMemberId: request.insuredMemberId,
      insuredMemberName: 'Family Member',
      policyName: request.policyName,
      policyType: InsurancePolicyModel.parseType(request.policyType),
      policyNumber: request.policyNumber,
      sumAssured: request.sumAssured,
      premiumAmount: request.premiumAmount,
      premiumFrequency: request.premiumFrequency,
      renewalDueDate: DateTime.tryParse(request.renewalDueDate) ?? DateTime.now(),
      status: InsurancePolicyModel.parseStatus(request.status),
    );
    return policy;
  }

  @override
  Future<void> deletePolicy(String policyId) async {}

  @override
  Future<InsurancePolicyModel> updatePolicy(
      String policyId, Map<String, dynamic> patch) async {
    final pol = InsurancePolicyModel(
      id: policyId,
      familyId: 'mock_family_1',
      insuredMemberId: patch['insured_member_id']?.toString() ?? 'm1',
      insuredMemberName: 'Family Member',
      policyName: patch['policy_name']?.toString() ?? 'Updated Policy',
      policyType: InsurancePolicyModel.parseType(patch['policy_type']?.toString()),
      policyNumber: patch['policy_number']?.toString(),
      sumAssured: patch['sum_assured'] != null
          ? (patch['sum_assured'] as num).toDouble()
          : 1000000.0,
      premiumAmount: patch['premium_amount'] != null
          ? (patch['premium_amount'] as num).toDouble()
          : 15000.0,
      premiumFrequency: patch['premium_frequency']?.toString() ?? 'ANNUAL',
      renewalDueDate: patch['renewal_due_date'] != null
          ? DateTime.tryParse(patch['renewal_due_date'].toString()) ??
              DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      status: InsurancePolicyModel.parseStatus(patch['status']?.toString()),
    );
    return pol;
  }
}
