import '../utils/currency_formatter.dart';

class SinkingFundGoal {
  final String id;
  final String title;
  final double currentAmount;
  final double targetGoal;
  final double percentage;
  final String neededText;
  final String paceStatus;
  final String? bannerAssetOrUrl;
  final List<String> memberInitials; // e.g. ['P', 'A'] or ['F']
  final bool isSecondaryPurple; // true for Durga Puja gradient, false for Cyan
  final String? startDate;
  final String? endDate;

  const SinkingFundGoal({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetGoal,
    required this.percentage,
    required this.neededText,
    required this.paceStatus,
    this.bannerAssetOrUrl,
    required this.memberInitials,
    this.isSecondaryPurple = true,
    this.startDate,
    this.endDate,
  });

  factory SinkingFundGoal.fromApiResponse(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Festival / Trip Pool';

    final currentAmount = double.tryParse(json['total_spent']?.toString() ??
            json['current_amount']?.toString() ??
            '0') ??
        0.0;
    final targetGoal = double.tryParse(
            json['budget_cap']?.toString() ?? json['target_goal']?.toString() ?? '0') ??
        0.0;

    final percentage = (json['percentage_used'] as num?)?.toDouble() ??
        (json['percentage'] as num?)?.toDouble() ??
        (targetGoal > 0 ? (currentAmount / targetGoal * 100) : 0.0);

    final needed = targetGoal - currentAmount;
    final String neededText;
    if (needed > 0) {
      neededText = '${CurrencyFormatter.formatInr(needed)} needed';
    } else if (needed == 0) {
      neededText = 'Target fully funded';
    } else {
      neededText = '${CurrencyFormatter.formatInr(needed.abs())} over budget';
    }

    final status = json['status']?.toString().toUpperCase() ?? 'ACTIVE';
    final String paceStatus;
    if (status == 'ACTIVE') {
      paceStatus = percentage > 85 ? 'Pacing high' : 'Active shared pool';
    } else if (status == 'COMPLETED') {
      paceStatus = 'Completed pool';
    } else {
      paceStatus = 'Archived';
    }

    final count = json['contributing_members_count'] as int? ?? 1;
    final initials = <String>[];
    if (count >= 1) initials.add('A');
    if (count >= 2) initials.add('P');
    if (count >= 3) initials.add('AY');

    return SinkingFundGoal(
      id: id,
      title: title,
      currentAmount: currentAmount,
      targetGoal: targetGoal,
      percentage: percentage,
      neededText: neededText,
      paceStatus: paceStatus,
      bannerAssetOrUrl: json['banner_url'] as String?,
      memberInitials: initials.isNotEmpty ? initials : const ['A'],
      isSecondaryPurple: true,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }

  factory SinkingFundGoal.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('budget_cap') || json.containsKey('percentage_used')) {
      return SinkingFundGoal.fromApiResponse(json);
    }
    return SinkingFundGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      currentAmount: (json['current_amount'] as num).toDouble(),
      targetGoal: (json['target_goal'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      neededText: json['needed_text'] as String,
      paceStatus: json['pace_status'] as String,
      bannerAssetOrUrl: json['banner_url'] as String?,
      memberInitials:
          (json['member_initials'] as List<dynamic>?)?.cast<String>() ??
              const ['A'],
      isSecondaryPurple: json['is_secondary_purple'] as bool? ?? true,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'current_amount': currentAmount,
        'target_goal': targetGoal,
        'percentage': percentage,
        'needed_text': neededText,
        'pace_status': paceStatus,
        'banner_url': bannerAssetOrUrl,
        'member_initials': memberInitials,
        'is_secondary_purple': isSecondaryPurple,
        'start_date': startDate,
        'end_date': endDate,
      };
}
