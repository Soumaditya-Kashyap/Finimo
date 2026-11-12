import 'package:flutter/material.dart';
import '../models/transaction_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CategorySelectorGrid extends StatelessWidget {
  final List<TransactionCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  const CategorySelectorGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category',
              style: AppTypography.labelMd(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (categories.isNotEmpty)
              Text(
                '${categories.length} available',
                style: AppTypography.labelSm(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (categories.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface01,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ghostBorder),
            ),
            child: const Text(
              'No categories found',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          )
        else
          // Dynamic Grid of Category Pills
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategoryId == cat.id;

              return InkWell(
                onTap: () => onSelected(cat.id),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface02 : AppColors.surface01,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryFixed : AppColors.ghostBorder,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryFixed.withValues(alpha: 0.12),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat.icon,
                        size: 15,
                        color: isSelected ? AppColors.primaryFixed : cat.iconColor,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSm(
                            color: isSelected ? AppColors.primaryFixed : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ).copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
