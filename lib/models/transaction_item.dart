enum TransactionType { expense, income, transfer }

class TransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final String attributionName;
  final String attributionTagColor; // 'purple' | 'lime' | 'cyan'
  final String iconKey; // 'smartphone', 'shopping_bag', 'stethoscope'

  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.attributionName,
    required this.attributionTagColor,
    required this.iconKey,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] as String? ?? 'EXPENSE').toUpperCase(),
        orElse: () => TransactionType.expense,
      ),
      attributionName: json['attribution_name'] as String,
      attributionTagColor: json['attribution_tag_color'] as String? ?? 'lime',
      iconKey: json['icon_key'] as String? ?? 'shopping_bag',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'amount': amount,
    'type': type.name.toUpperCase(),
    'attribution_name': attributionName,
    'attribution_tag_color': attributionTagColor,
    'icon_key': iconKey,
  };
}
