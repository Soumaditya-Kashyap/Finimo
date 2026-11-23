import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/insurance_policy_model.dart';
import 'insurance_repository.dart';

class HttpInsuranceRepository implements InsuranceRepository {
  final ApiClient apiClient;

  HttpInsuranceRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<InsuranceVaultOverview> getInsuranceOverview() async {
    final response = await apiClient.get(
      ApiConfig.insurance,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return InsuranceVaultOverview.fromApiResponse(response);
    }

    throw ApiException(
      statusCode: 500,
      message: 'Unexpected insurance response format from server',
    );
  }

  @override
  Future<InsurancePolicyModel> createPolicy(
      CreateInsuranceRequest request) async {
    final response = await apiClient.post(
      ApiConfig.insurance,
      body: request.toJson(),
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return InsurancePolicyModel.fromApiResponse(response);
    }

    throw ApiException(
      statusCode: 500,
      message: 'Failed to create insurance policy on server',
    );
  }

  @override
  Future<void> deletePolicy(String policyId) async {
    await apiClient.delete(
      ApiConfig.insuranceById(policyId),
      requiresAuth: true,
    );
  }

  @override
  Future<InsurancePolicyModel> updatePolicy(
    String policyId,
    Map<String, dynamic> patch,
  ) async {
    final response = await apiClient.patch(
      ApiConfig.insuranceById(policyId),
      body: patch,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return InsurancePolicyModel.fromApiResponse(response);
    }

    throw ApiException(
      statusCode: 500,
      message: 'Failed to update insurance policy on server',
    );
  }
}
