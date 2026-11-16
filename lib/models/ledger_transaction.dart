import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'transaction_category.dart';

class LedgerTransaction {
  final String id;
  final String title;
  final String categoryName;
  final double amount;
  final bool isExpense;
  final String timeString; // e.g., '18:42'
  final String dateSection; // 'Today' | 'Yesterday' | '12 Nov 2026'
  final String payerInitial;
  final String payerName;
  final String beneficiaryName;
  final String? badgeText; // 'Event', 'Cash', 'Primary Inflow', etc.
  final Color? badgeColor;
  final IconData icon;
  final bool isMultiBeneficiary;
  final DateTime? transactionDate;
  final String? categoryId;
  final String? categoryIconKey;
  final String? categoryColorHex;
  final String? paymentMode;
  final String? notes;
  final String? eventId;
  final String? paidByMemberId;
  final String? beneficiaryMemberId;

  const LedgerTransaction({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.amount,
    required this.isExpense,
    required this.timeString,
    required this.dateSection,
    required this.payerInitial,
    required this.payerName,
    required this.beneficiaryName,
    this.badgeText,
    this.badgeColor,
    required this.icon,
    this.isMultiBeneficiary = false,
    this.transactionDate,
    this.categoryId,
    this.categoryIconKey,
    this.categoryColorHex,
    this.paymentMode,
    this.notes,
    this.eventId,
    this.paidByMemberId,
    this.beneficiaryMemberId,
  });

  factory LedgerTransaction.fromApiResponse(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Transaction';
    final amountStr = json['amount']?.toString() ?? '0';
    final amount = double.tryParse(amountStr) ?? 0.0;
    final category = json['category'] as Map<String, dynamic>? ?? {};
    final categoryId = category['id']?.toString();
    final categoryName = category['name']?.toString() ?? 'General';
    final categoryIconKey = category['icon_key']?.toString();
    final categoryColorHex = category['color_hex']?.toString();
    final categoryType = category['type']?.toString().toUpperCase();
    final icon = TransactionCategory.getIconFromKey(categoryIconKey);

    final typeStr = json['type']?.toString().toUpperCase() ?? 'EXPENSE';
    final isExpense = typeStr == 'INCOME' || categoryType == 'INCOME' ? false : true;

    final rawDate = json['transaction_date']?.toString();
    DateTime parsedDate = DateTime.now();
    if (rawDate != null) {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        parsedDate = dt.toLocal();
      }
    }

    final hours = parsedDate.hour.toString().padLeft(2, '0');
    final minutes = parsedDate.minute.toString().padLeft(2, '0');
    final timeString = '$hours:$minutes';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final diff = today.difference(txDay).inDays;

    String dateSection;
    if (diff == 0) {
      dateSection = 'Today';
    } else if (diff == 1) {
      dateSection = 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateSection =
          '${txDay.day.toString().padLeft(2, '0')} ${months[txDay.month - 1]} ${txDay.year}';
    }

    final paidBy = json['paid_by'] as Map<String, dynamic>? ?? {};
    final paidByMemberId =
        paidBy['id']?.toString() ?? json['paid_by_member_id']?.toString();
    final payerName = paidBy['name']?.toString() ?? 'Family Member';
    final payerInitial =
        payerName.trim().isNotEmpty ? payerName.trim()[0].toUpperCase() : 'A';

    final beneficiary = json['beneficiary'] as Map<String, dynamic>?;
    final beneficiaryMemberId = beneficiary?['id']?.toString() ??
        json['beneficiary_member_id']?.toString();
    final String beneficiaryName;
    final bool isMultiBeneficiary;
    if (beneficiary != null &&
        beneficiary['name'] != null &&
        beneficiary['name'].toString().trim().isNotEmpty) {
      beneficiaryName = beneficiary['name'].toString().trim();
      isMultiBeneficiary = false;
    } else {
      beneficiaryName = 'Entire Family';
      isMultiBeneficiary = true;
    }

    final eventId = json['event_id']?.toString();
    final paymentMode = json['payment_mode']?.toString();
    final notes = json['notes']?.toString();

    String? badgeText;
    Color? badgeColor;
    if (eventId != null && eventId.isNotEmpty) {
      badgeText = 'Event';
      badgeColor = AppColors.secondary;
    } else if (!isExpense) {
      badgeText = 'Primary Inflow';
      badgeColor = AppColors.primaryFixed;
    } else if (paymentMode != null &&
        paymentMode.isNotEmpty &&
        paymentMode.toUpperCase() != 'UPI') {
      badgeText = paymentMode.toUpperCase();
      badgeColor = AppColors.secondary;
    }

    return LedgerTransaction(
      id: id,
      title: title,
      categoryName: categoryName,
      amount: amount,
      isExpense: isExpense,
      timeString: timeString,
      dateSection: dateSection,
      payerInitial: payerInitial,
      payerName: payerName,
      beneficiaryName: beneficiaryName,
      badgeText: badgeText,
      badgeColor: badgeColor,
      icon: icon,
      isMultiBeneficiary: isMultiBeneficiary,
      transactionDate: parsedDate,
      categoryId: categoryId,
      categoryIconKey: categoryIconKey,
      categoryColorHex: categoryColorHex,
      paymentMode: paymentMode,
      notes: notes,
      eventId: eventId,
      paidByMemberId: paidByMemberId,
      beneficiaryMemberId: beneficiaryMemberId,
    );
  }

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('category') && json['category'] is Map) {
      return LedgerTransaction.fromApiResponse(json);
    }
    return LedgerTransaction(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Transaction',
      categoryName: json['category_name'] as String? ?? 'General',
      amount: (json['amount'] as num?)?.toDouble() ??
          double.tryParse(json['amount']?.toString() ?? '0') ??
          0.0,
      isExpense: json['is_expense'] as bool? ?? true,
      timeString: json['time_string'] as String? ?? '',
      dateSection: json['date_section'] as String? ?? 'Today',
      payerInitial: json['payer_initial'] as String? ?? 'A',
      payerName: json['payer_name'] as String? ?? 'Family Member',
      beneficiaryName: json['beneficiary_name'] as String? ?? 'Entire Family',
      badgeText: json['badge_text'] as String?,
      icon: Icons.receipt_long_outlined,
      isMultiBeneficiary: json['is_multi_beneficiary'] as bool? ?? false,
      transactionDate: json['transaction_date'] != null
          ? DateTime.tryParse(json['transaction_date'].toString())
          : null,
      categoryId: json['category_id'] as String?,
      categoryIconKey: json['category_icon_key'] as String?,
      categoryColorHex: json['category_color_hex'] as String?,
      paymentMode: json['payment_mode'] as String?,
      notes: json['notes'] as String?,
      eventId: json['event_id'] as String?,
      paidByMemberId: json['paid_by_member_id'] as String?,
      beneficiaryMemberId: json['beneficiary_member_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category_name': categoryName,
        'amount': amount,
        'is_expense': isExpense,
        'time_string': timeString,
        'date_section': dateSection,
        'payer_initial': payerInitial,
        'payer_name': payerName,
        'beneficiary_name': beneficiaryName,
        'badge_text': badgeText,
        'is_multi_beneficiary': isMultiBeneficiary,
        'transaction_date': transactionDate?.toIso8601String(),
        'category_id': categoryId,
        'category_icon_key': categoryIconKey,
        'category_color_hex': categoryColorHex,
        'payment_mode': paymentMode,
        'notes': notes,
        'event_id': eventId,
        'paid_by_member_id': paidByMemberId,
        'beneficiary_member_id': beneficiaryMemberId,
      };
}
