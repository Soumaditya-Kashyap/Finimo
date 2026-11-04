import '../models/conjoined_event_summary.dart';
import '../models/home_dashboard_data.dart';
export 'http_dashboard_repository.dart';

abstract class DashboardRepository {
  Future<HomeDashboardData> getDashboardMetrics({
    int? month,
    int? year,
    String? memberId,
  });

  Future<ConjoinedEventSummary?> getActiveConjoinedEvent();
}

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<HomeDashboardData> getDashboardMetrics({
    int? month,
    int? year,
    String? memberId,
  }) async {
    return const HomeDashboardData(
      consolidatedLiquidity: 142850.00,
      jointAccountsCount: 4,
      monthlyInflow: 85000.00,
      monthlySpent: 58281.00,
      dailySafeBurn: 1445.00,
      livePingSeconds: '04S',
    );
  }

  @override
  Future<ConjoinedEventSummary?> getActiveConjoinedEvent() async {
    return const ConjoinedEventSummary(
      id: 'event_durga_puja_2026',
      title: 'Durga Puja 2026',
      budgetCap: 10000.00,
      totalSpent: 8672.00,
      remainingBudget: 1328.00,
      percentageUsed: 86.7,
      contributingMembersCount: 3,
    );
  }
}

