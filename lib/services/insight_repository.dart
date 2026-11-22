import '../models/deep_dive_models.dart';
export 'http_insight_repository.dart';

abstract class InsightRepository {
  Future<DeepDiveSummaryData> getInsightsSummary({
    int? month,
    int? year,
    String? memberId,
  });
}
