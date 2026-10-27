import 'package:flutter/material.dart';

class LedgerTransaction {
  final String id;
  final String title;
  final String categoryName;
  final double amount;
  final bool isExpense;
  final String timeString; // e.g., '18:42'
  final String dateSection; // 'Today' | 'Yesterday' | 'Earlier'
  final String payerInitial;
  final String payerName;
  final String beneficiaryName;
  final String? badgeText; // 'Pujo 2026', 'Child Care', 'Auto-Debit', 'Primary Inflow'
  final Color? badgeColor;
  final IconData icon;
  final bool isMultiBeneficiary;

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
  });

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    return LedgerTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      categoryName: json['category_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      isExpense: json['is_expense'] as bool? ?? true,
      timeString: json['time_string'] as String,
      dateSection: json['date_section'] as String,
      payerInitial: json['payer_initial'] as String? ?? 'A',
      payerName: json['payer_name'] as String,
      beneficiaryName: json['beneficiary_name'] as String,
      badgeText: json['badge_text'] as String?,
      icon: Icons.receipt_long_outlined,
      isMultiBeneficiary: json['is_multi_beneficiary'] as bool? ?? false,
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
  };
}
