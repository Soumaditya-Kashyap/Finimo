enum TransactionType { expense, income, transfer }

class TransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final String attributionName;
  final String attributionTagColor; // 'purple' | 'lime' | 'cyan'
  final String iconKey; // 'smartphone', 'shopping_bag', 'stethoscope', 'dining', etc.

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
    if (json.containsKey('category') && json['category'] is Map) {
      return TransactionItem.fromApiResponse(json);
    }

    return TransactionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num?)?.toDouble() ??
          double.tryParse(json['amount']?.toString() ?? '0') ??
          0.0,
      type: TransactionType.values.firstWhere(
        (e) =>
            e.name.toUpperCase() ==
            (json['type'] as String? ?? 'EXPENSE').toUpperCase(),
        orElse: () => TransactionType.expense,
      ),
      attributionName: json['attribution_name'] as String? ?? 'Family',
      attributionTagColor: json['attribution_tag_color'] as String? ?? 'lime',
      iconKey: json['icon_key'] as String? ?? 'shopping_bag',
    );
  }

  factory TransactionItem.fromApiResponse(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Transaction';

    final amountStr = json['amount']?.toString() ?? '0';
    final amount = double.tryParse(amountStr) ?? 0.0;

    final typeStr = json['type']?.toString().toUpperCase() ?? 'EXPENSE';
    final type =
        typeStr == 'INCOME' ? TransactionType.income : TransactionType.expense;

    final category = json['category'] as Map<String, dynamic>? ?? {};
    final categoryName = category['name']?.toString() ?? 'General';
    final categoryIcon = category['icon_key']?.toString() ?? 'shopping_bag';

    // Parse date for subtitle e.g. "08 Oct"
    String datePart = '';
    final rawDate = json['transaction_date']?.toString();
    if (rawDate != null) {
      final parsedDate = DateTime.tryParse(rawDate);
      if (parsedDate != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final day = parsedDate.day.toString().padLeft(2, '0');
        final month = months[parsedDate.month - 1];
        datePart = '$day $month';
      }
    }
    final subtitle = datePart.isNotEmpty
        ? '$datePart · ${categoryName.toUpperCase()}'
        : categoryName.toUpperCase();

    final paidBy = json['paid_by'] as Map<String, dynamic>? ?? {};
    final attributionName = paidBy['name']?.toString() ?? 'Family';
    final relationType = paidBy['relation_type']?.toString().toUpperCase();

    String tagColor = 'lime';
    if (relationType == 'SPOUSE') {
      tagColor = 'purple';
    } else if (relationType == 'CHILD' || relationType == 'PARENT') {
      tagColor = 'cyan';
    }

    return TransactionItem(
      id: id,
      title: title,
      subtitle: subtitle,
      amount: amount,
      type: type,
      attributionName: attributionName,
      attributionTagColor: tagColor,
      iconKey: categoryIcon,
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
