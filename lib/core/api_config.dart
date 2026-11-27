/// Central API Configuration and Endpoints for FINIMO
///
/// Ideal place where all base URLs, API versions, and routes reside.
/// Environment base URLs can be overridden via dart-define during build:
/// flutter run --dart-define=API_BASE_URL=https://...
class ApiConfig {
  ApiConfig._();

  /// Default remote backend server URL (FastAPI / Swagger docs at https://8000.13.233.93.251.sslip.io/docs)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://8000.13.233.93.251.sslip.io',
  );

  /// Resilient fallback backend URL (Direct IP:Port if ISP DNS blocks *.sslip.io)
  static const String fallbackBaseUrl = String.fromEnvironment(
    'API_FALLBACK_BASE_URL',
    defaultValue: 'http://13.233.93.251:8000',
  );

  static const String apiVersion = '/api/v1';

  // Request timeout duration (30s for resilient mobile 4G/5G handoffs)
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // -------------------------------------------------------------
  // Auth Endpoints
  // -------------------------------------------------------------
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String logoutAll = '$apiVersion/auth/logout-all';
  static const String changePassword = '$apiVersion/auth/change-password';
  static const String me = '$apiVersion/auth/me';

  // -------------------------------------------------------------
  // Family & Members
  // -------------------------------------------------------------
  static const String family = '$apiVersion/family';
  static const String familyMembers = '$apiVersion/family/members';
  static String familyMemberById(String id) => '$apiVersion/family/members/$id';
  static String familyMemberRole(String id) =>
      '$apiVersion/family/members/$id/role';
  static const String familyInvitations = '$apiVersion/family/invitations';
  static String familyInvitationById(String id) =>
      '$apiVersion/family/invitations/$id';
  static const String invitationPreview = '$apiVersion/invitations/preview';
  static const String invitationAccept = '$apiVersion/invitations/accept';

  // -------------------------------------------------------------
  // Categories Taxonomy
  // -------------------------------------------------------------
  static const String categories = '$apiVersion/categories';
  static String categoryById(String id) => '$apiVersion/categories/$id';

  // -------------------------------------------------------------
  // Transactions & Ledger
  // -------------------------------------------------------------
  static const String transactions = '$apiVersion/transactions';
  static String transactionById(String id) => '$apiVersion/transactions/$id';

  // -------------------------------------------------------------
  // Conjoined Events (Sinking Funds)
  // -------------------------------------------------------------
  static const String events = '$apiVersion/events';
  static String eventById(String id) => '$apiVersion/events/$id';
  static String eventItems(String id) => '$apiVersion/events/$id/items';
  static String eventAddReceipt(String id) =>
      '$apiVersion/events/$id/add-receipt';

  // -------------------------------------------------------------
  // Targets & Budget Limits
  // -------------------------------------------------------------
  static const String targets = '$apiVersion/targets';
  static String targetById(String id) => '$apiVersion/targets/$id';

  // -------------------------------------------------------------
  // Insurance Vault
  // -------------------------------------------------------------
  static const String insurance = '$apiVersion/insurance';
  static String insuranceById(String id) => '$apiVersion/insurance/$id';

  // -------------------------------------------------------------
  // Insights & Deep Dive Aggregation
  // -------------------------------------------------------------
  static const String insightsSummary = '$apiVersion/insights/summary';

  // -------------------------------------------------------------
  // Health checks
  // -------------------------------------------------------------
  static const String healthLive = '/health/live';
  static const String healthReady = '/health/ready';
}
