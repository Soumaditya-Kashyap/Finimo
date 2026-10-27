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

  factory ConjoinedEventDetail.fromJson(Map<String, dynamic> json) {
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
