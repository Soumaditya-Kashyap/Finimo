import 'package:flutter/material.dart';

class TransactionCategory {
  final String id;
  final String name;
  final String type; // 'EXPENSE' or 'INCOME'
  final String iconKey;
  final String colorHex;
  final IconData icon;
  final Color iconColor;

  const TransactionCategory({
    required this.id,
    required this.name,
    this.type = 'EXPENSE',
    this.iconKey = 'shopping_bag',
    this.colorHex = '#C3F400',
    required this.icon,
    required this.iconColor,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? 'General';
    final type = json['type']?.toString().toUpperCase() ?? 'EXPENSE';
    final iconKey = json['icon_key']?.toString() ?? 'tag';
    final colorHex = json['color_hex']?.toString() ?? '#C3F400';

    final icon = getIconFromKey(iconKey);
    final iconColor = getColorFromHex(colorHex);

    return TransactionCategory(
      id: id,
      name: name,
      type: type,
      iconKey: iconKey,
      colorHex: colorHex,
      icon: icon,
      iconColor: iconColor,
    );
  }

  static IconData getIconFromKey(String? iconKey) {
    switch (iconKey?.toLowerCase()) {
      case 'shopping-cart':
      case 'shopping_cart':
        return Icons.shopping_cart_outlined;
      case 'utensils':
      case 'dining':
        return Icons.restaurant_outlined;
      case 'shirt':
      case 'garments':
        return Icons.checkroom_outlined;
      case 'heart-pulse':
      case 'medical':
        return Icons.medical_services_outlined;
      case 'home':
      case 'household':
        return Icons.home_outlined;
      case 'zap':
      case 'utilities':
        return Icons.bolt_outlined;
      case 'car':
      case 'transport':
        return Icons.directions_car_outlined;
      case 'film':
      case 'entertainment':
        return Icons.movie_outlined;
      case 'graduation-cap':
      case 'education':
        return Icons.school_outlined;
      case 'sparkles':
      case 'festival':
        return Icons.auto_awesome_outlined;
      case 'shield-check':
      case 'insurance':
        return Icons.shield_outlined;
      case 'briefcase':
      case 'salary':
        return Icons.work_outline;
      case 'trending-up':
      case 'business':
        return Icons.trending_up_outlined;
      case 'gift':
        return Icons.card_giftcard_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  static Color getColorFromHex(String? hex,
      {Color defaultColor = const Color(0xFFC3F400)}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final cleanHex = hex.replaceFirst('#', '');
    if (cleanHex.length == 6) {
      final val = int.tryParse('FF$cleanHex', radix: 16);
      if (val != null) return Color(val);
    }
    return defaultColor;
  }

  static const List<TransactionCategory> defaultCategories = [
    TransactionCategory(
      id: 'household',
      name: 'Household',
      type: 'EXPENSE',
      iconKey: 'home',
      colorHex: '#3B82F6',
      icon: Icons.home_outlined,
      iconColor: Color(0xFFA6CF00),
    ),
    TransactionCategory(
      id: 'groceries',
      name: 'Groceries',
      type: 'EXPENSE',
      iconKey: 'shopping-cart',
      colorHex: '#10B981',
      icon: Icons.shopping_cart_outlined,
      iconColor: Color(0xFFC3F400),
    ),
    TransactionCategory(
      id: 'medical',
      name: 'Medical',
      type: 'EXPENSE',
      iconKey: 'heart-pulse',
      colorHex: '#EF4444',
      icon: Icons.medical_services_outlined,
      iconColor: Color(0xFFFF453A),
    ),
    TransactionCategory(
      id: 'dining',
      name: 'Dining',
      type: 'EXPENSE',
      iconKey: 'utensils',
      colorHex: '#F59E0B',
      icon: Icons.restaurant_outlined,
      iconColor: Color(0xFFE9B3FF),
    ),
    TransactionCategory(
      id: 'emis',
      name: 'EMIs',
      type: 'EXPENSE',
      iconKey: 'wallet',
      colorHex: '#00DCE5',
      icon: Icons.account_balance_outlined,
      iconColor: Color(0xFF00DCE5),
    ),
    TransactionCategory(
      id: 'garments',
      name: 'Garments',
      type: 'EXPENSE',
      iconKey: 'shirt',
      colorHex: '#8B5CF6',
      icon: Icons.checkroom_outlined,
      iconColor: Color(0xFFF6D9FF),
    ),
  ];
}
