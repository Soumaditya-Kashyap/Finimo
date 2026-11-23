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
    throw UnimplementedError();
  }
}
