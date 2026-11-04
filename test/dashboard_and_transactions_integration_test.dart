import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finimo/core/api_client.dart';
import 'package:finimo/core/token_storage.dart';
import 'package:finimo/models/transaction_item.dart';
import 'package:finimo/services/http_dashboard_repository.dart';
import 'package:finimo/services/http_transaction_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Dashboard and Transactions Integration Tests', () {
    test('HttpDashboardRepository parses insights summary correctly', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/insights/summary')) {
          return http.Response(
            jsonEncode({
              'period': {
                'month': 11,
                'year': 2026,
                'timezone': 'Asia/Kolkata',
              },
              'consolidated_liquidity': '142850.00',
              'total_monthly_income': '85000.00',
              'total_monthly_expense': '58281.00',
              'daily_safe_to_spend': '1445.00',
              'budget_health_score_pct': 74,
              'category_breakdown': [],
              'event_summaries': [],
              'member_breakdown': [],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path.endsWith('/api/v1/family')) {
          return http.Response(
            jsonEncode({
              'id': 'fam_123',
              'family_name': 'Mehta Family',
              'currency': 'INR',
              'timezone': 'Asia/Kolkata',
              'members_count': 4,
              'active_members_count': 4,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpDashboardRepository(apiClient: apiClient);

      final metrics = await repo.getDashboardMetrics();

      expect(metrics.consolidatedLiquidity, 142850.00);
      expect(metrics.monthlyInflow, 85000.00);
      expect(metrics.monthlySpent, 58281.00);
      expect(metrics.dailySafeBurn, 1445.00);
      expect(metrics.jointAccountsCount, 4);
    });

    test('HttpDashboardRepository parses active event correctly', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/events')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'ev_durga_puja_2026',
                'family_id': 'fam_123',
                'title': 'Durga Puja 2026',
                'budget_cap': '10000.00',
                'total_spent': '8672.00',
                'remaining_budget': '1328.00',
                'percentage_used': 86.7,
                'item_count': 5,
                'is_over_budget': false,
                'status': 'ACTIVE',
                'start_date': '2026-10-01',
                'created_at': '2026-10-01T00:00:00Z',
                'updated_at': '2026-10-08T00:00:00Z',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpDashboardRepository(apiClient: apiClient);

      final event = await repo.getActiveConjoinedEvent();

      expect(event, isNotNull);
      expect(event!.title, 'Durga Puja 2026');
      expect(event.budgetCap, 10000.00);
      expect(event.totalSpent, 8672.00);
      expect(event.remainingBudget, 1328.00);
      expect(event.percentageUsed, 86.7);
      expect(event.contributingMembersCount, 5);
    });

    test('HttpTransactionRepository parses transactions response correctly',
        () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/transactions')) {
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': 'tx_123',
                  'family_id': 'fam_123',
                  'type': 'EXPENSE',
                  'amount': '4025.00',
                  'title': 'FabIndia Garments',
                  'category': {
                    'id': 'cat_1',
                    'name': 'Ethnic Wear',
                    'type': 'EXPENSE',
                    'icon_key': 'shopping_bag',
                    'color_hex': '#BF5AF2',
                  },
                  'paid_by': {
                    'id': 'mem_chandrani',
                    'name': 'Chandrani',
                    'relation_type': 'SPOUSE',
                  },
                  'transaction_date': '2026-10-08T14:30:00Z',
                  'payment_mode': 'UPI',
                  'created_at': '2026-10-08T14:30:00Z',
                  'updated_at': '2026-10-08T14:30:00Z',
                }
              ],
              'next_cursor': null,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpTransactionRepository(apiClient: apiClient);

      final transactions = await repo.getRecentTransactions(limit: 5);

      expect(transactions.length, 1);
      final tx = transactions.first;
      expect(tx.title, 'FabIndia Garments');
      expect(tx.amount, 4025.00);
      expect(tx.type, TransactionType.expense);
      expect(tx.attributionName, 'Chandrani');
      expect(tx.attributionTagColor, 'purple');
      expect(tx.subtitle.contains('ETHNIC WEAR'), isTrue);
    });
  });
}
