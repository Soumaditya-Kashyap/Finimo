import 'package:flutter/material.dart';

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconColor,
  });

  static const List<TransactionCategory> defaultCategories = [
    TransactionCategory(
      id: 'household',
      name: 'Household',
      icon: Icons.home_outlined,
      iconColor: Color(0xFFA6CF00), // lime-dim
    ),
    TransactionCategory(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_cart_outlined,
      iconColor: Color(0xFFC3F400), // primaryFixed
    ),
    TransactionCategory(
      id: 'medical',
      name: 'Medical',
      icon: Icons.medical_services_outlined,
      iconColor: Color(0xFFFF453A), // dangerCoral
    ),
    TransactionCategory(
      id: 'dining',
      name: 'Dining',
      icon: Icons.restaurant_outlined,
      iconColor: Color(0xFFE9B3FF), // secondary
    ),
    TransactionCategory(
      id: 'emis',
      name: 'EMIs',
      icon: Icons.account_balance_outlined,
      iconColor: Color(0xFF00DCE5), // tertiaryFixedDim
    ),
    TransactionCategory(
      id: 'garments',
      name: 'Garments',
      icon: Icons.checkroom_outlined,
      iconColor: Color(0xFFF6D9FF), // secondaryFixed
    ),
  ];
}
