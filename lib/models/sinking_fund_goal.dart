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
  });

  factory SinkingFundGoal.fromJson(Map<String, dynamic> json) {
    return SinkingFundGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      currentAmount: (json['current_amount'] as num).toDouble(),
      targetGoal: (json['target_goal'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      neededText: json['needed_text'] as String,
      paceStatus: json['pace_status'] as String,
      bannerAssetOrUrl: json['banner_url'] as String?,
      memberInitials: (json['member_initials'] as List<dynamic>?)?.cast<String>() ?? ['A'],
      isSecondaryPurple: json['is_secondary_purple'] as bool? ?? true,
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
  };
}
