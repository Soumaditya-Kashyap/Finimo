class EventMemberEquity {
  final String memberId;
  final String name;
  final String initial;
  final double amount;
  final double ratioPercentage;
  final int accentColorValue;

  const EventMemberEquity({
    required this.memberId,
    required this.name,
    required this.initial,
    required this.amount,
    required this.ratioPercentage,
    required this.accentColorValue,
  });

  factory EventMemberEquity.fromJson(Map<String, dynamic> json) {
    return EventMemberEquity(
      memberId: json['memberId'] as String,
      name: json['name'] as String,
      initial: json['initial'] as String,
      amount: (json['amount'] as num).toDouble(),
      ratioPercentage: (json['ratioPercentage'] as num).toDouble(),
      accentColorValue: json['accentColorValue'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'name': name,
        'initial': initial,
        'amount': amount,
        'ratioPercentage': ratioPercentage,
        'accentColorValue': accentColorValue,
      };
}

class EventLedgerRecord {
  final String id;
  final String title;
  final String dateString;
  final String categoryTag;
  final double amount;
  final bool isCreditInflow;
  final String paidByOrRecipient;
  final String paidByInitial;
  final int paidByColorValue;
  final int categoryIconCode;

  const EventLedgerRecord({
    required this.id,
    required this.title,
    required this.dateString,
    required this.categoryTag,
    required this.amount,
    this.isCreditInflow = false,
    required this.paidByOrRecipient,
    required this.paidByInitial,
    required this.paidByColorValue,
    required this.categoryIconCode,
  });

  factory EventLedgerRecord.fromJson(Map<String, dynamic> json) {
    return EventLedgerRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      dateString: json['dateString'] as String,
      categoryTag: json['categoryTag'] as String,
      amount: (json['amount'] as num).toDouble(),
      isCreditInflow: json['isCreditInflow'] as bool? ?? false,
      paidByOrRecipient: json['paidByOrRecipient'] as String,
      paidByInitial: json['paidByInitial'] as String,
      paidByColorValue: json['paidByColorValue'] as int,
      categoryIconCode: json['categoryIconCode'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateString': dateString,
        'categoryTag': categoryTag,
        'amount': amount,
        'isCreditInflow': isCreditInflow,
        'paidByOrRecipient': paidByOrRecipient,
        'paidByInitial': paidByInitial,
        'paidByColorValue': paidByColorValue,
        'categoryIconCode': categoryIconCode,
      };
}

class ConjoinedEventDetail {
  final String id;
  final String eventTitle;
  final String poolTag;
  final String poolSubtype;
  final double totalSunkVolume;
  final double budgetCap;
  final double spentPercentage;
  final double remainingBuffer;
  final int activeMembersCount;
  final List<String> memberInitials;
  final double avgDailyBurn;
  final List<EventMemberEquity> memberSplits;
  final List<EventLedgerRecord> ledgerRecords;

  const ConjoinedEventDetail({
    required this.id,
    required this.eventTitle,
    required this.poolTag,
    required this.poolSubtype,
    required this.totalSunkVolume,
    required this.budgetCap,
    required this.spentPercentage,
    required this.remainingBuffer,
    required this.activeMembersCount,
    required this.memberInitials,
    required this.avgDailyBurn,
    required this.memberSplits,
    required this.ledgerRecords,
  });

  factory ConjoinedEventDetail.fromEventItemsResponse(
      Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>? ?? json;
    final items = json['items'] as List? ?? [];

    final id = event['id']?.toString() ?? '';
    final title = event['title']?.toString() ?? 'Conjoined Event';
    final budgetCap =
        double.tryParse(event['budget_cap']?.toString() ?? '0') ?? 0.0;
    final totalSunkVolume =
        double.tryParse(event['total_spent']?.toString() ?? '0') ?? 0.0;
    final remainingBuffer =
        double.tryParse(event['remaining_budget']?.toString() ?? '0') ??
            (budgetCap > totalSunkVolume ? budgetCap - totalSunkVolume : 0.0);
    final spentPercentage = (event['percentage_used'] as num?)?.toDouble() ??
        (budgetCap > 0 ? (totalSunkVolume / budgetCap * 100) : 0.0);

    // Compute dynamic member equity splits from items
    final splitsMap = <String, _MemberAccumulator>{};
    for (final raw in items) {
      if (raw is Map<String, dynamic>) {
        final paidBy = raw['paid_by'] as Map<String, dynamic>? ?? {};
        final memberId = paidBy['id']?.toString() ?? 'unknown';
        final name = paidBy['name']?.toString() ?? 'Member';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
        final amount = double.tryParse(raw['amount']?.toString() ?? '0') ?? 0.0;

        splitsMap
            .putIfAbsent(
                memberId, () => _MemberAccumulator(memberId, name, initial))
            .total += amount;
      }
    }

    final memberSplits = <EventMemberEquity>[];
    const colors = [0xFFC3F400, 0xFF63F7FF, 0xFFFF453A, 0xFFE040FB];
    int colorIdx = 0;
    for (final acc in splitsMap.values) {
      final ratio =
          totalSunkVolume > 0 ? (acc.total / totalSunkVolume * 100) : 0.0;
      memberSplits.add(EventMemberEquity(
        memberId: acc.memberId,
        name: acc.name,
        initial: acc.initial,
        amount: acc.total,
        ratioPercentage: ratio,
        accentColorValue: colors[colorIdx % colors.length],
      ));
      colorIdx++;
    }

    // Compute ledger records from items
    final ledgerRecords = <EventLedgerRecord>[];
    for (final raw in items) {
      if (raw is Map<String, dynamic>) {
        final rId = raw['id']?.toString() ?? '';
        final rTitle = raw['title']?.toString() ?? 'Receipt';
        final rAmount =
            double.tryParse(raw['amount']?.toString() ?? '0') ?? 0.0;
        final isCredit = raw['type']?.toString().toUpperCase() == 'INCOME';

        final category = raw['category'] as Map<String, dynamic>? ?? {};
        final categoryTag =
            (category['name']?.toString() ?? 'GENERAL').toUpperCase();

        final paidBy = raw['paid_by'] as Map<String, dynamic>? ?? {};
        final paidByName = paidBy['name']?.toString() ?? 'Family Member';
        final paidByInitial =
            paidByName.isNotEmpty ? paidByName[0].toUpperCase() : 'F';

        String dateString = 'Today';
        final rawDate = raw['transaction_date']?.toString();
        if (rawDate != null) {
          final dt = DateTime.tryParse(rawDate)?.toLocal();
          if (dt != null) {
            const months = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec'
            ];
            dateString =
                '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}';
          }
        }

        ledgerRecords.add(EventLedgerRecord(
          id: rId,
          title: rTitle,
          dateString: dateString,
          categoryTag: categoryTag,
          amount: rAmount,
          isCreditInflow: isCredit,
          paidByOrRecipient: paidByName,
          paidByInitial: paidByInitial,
          paidByColorValue: 0xFFC3F400,
          categoryIconCode: 0xe530, // receipt_long
        ));
      }
    }

    final activeCount = splitsMap.isNotEmpty
        ? splitsMap.length
        : (event['contributing_members_count'] as int? ?? 1);

    final initials = splitsMap.values.map((e) => e.initial).toList();
    if (initials.isEmpty) initials.addAll(['A', 'P']);

    return ConjoinedEventDetail(
      id: id,
      eventTitle: title,
      poolTag: 'FESTIVAL & SINKING POOL',
      poolSubtype: event['status']?.toString() == 'ACTIVE'
          ? 'Active Shared Pool'
          : (event['status']?.toString() ?? 'Sinking Pool'),
      totalSunkVolume: totalSunkVolume,
      budgetCap: budgetCap,
      spentPercentage: spentPercentage,
      remainingBuffer: remainingBuffer,
      activeMembersCount: activeCount,
      memberInitials: initials,
      avgDailyBurn: totalSunkVolume > 0 ? (totalSunkVolume / 30) : 0.0,
      memberSplits: memberSplits,
      ledgerRecords: ledgerRecords,
    );
  }

  factory ConjoinedEventDetail.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('event') || json.containsKey('budget_cap')) {
      return ConjoinedEventDetail.fromEventItemsResponse(json);
    }
    return ConjoinedEventDetail(
      id: json['id'] as String,
      eventTitle: json['eventTitle'] as String,
      poolTag: json['poolTag'] as String,
      poolSubtype: json['poolSubtype'] as String,
      totalSunkVolume: (json['totalSunkVolume'] as num).toDouble(),
      budgetCap: (json['budgetCap'] as num).toDouble(),
      spentPercentage: (json['spentPercentage'] as num).toDouble(),
      remainingBuffer: (json['remainingBuffer'] as num).toDouble(),
      activeMembersCount: json['activeMembersCount'] as int,
      memberInitials: (json['memberInitials'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      avgDailyBurn: (json['avgDailyBurn'] as num).toDouble(),
      memberSplits: (json['memberSplits'] as List<dynamic>)
          .map((e) => EventMemberEquity.fromJson(e as Map<String, dynamic>))
          .toList(),
      ledgerRecords: (json['ledgerRecords'] as List<dynamic>)
          .map((e) => EventLedgerRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventTitle': eventTitle,
        'poolTag': poolTag,
        'poolSubtype': poolSubtype,
        'totalSunkVolume': totalSunkVolume,
        'budgetCap': budgetCap,
        'spentPercentage': spentPercentage,
        'remainingBuffer': remainingBuffer,
        'activeMembersCount': activeMembersCount,
        'memberInitials': memberInitials,
        'avgDailyBurn': avgDailyBurn,
        'memberSplits': memberSplits.map((e) => e.toJson()).toList(),
        'ledgerRecords': ledgerRecords.map((e) => e.toJson()).toList(),
      };
}

class _MemberAccumulator {
  final String memberId;
  final String name;
  final String initial;
  double total = 0.0;

  _MemberAccumulator(this.memberId, this.name, this.initial);
}
