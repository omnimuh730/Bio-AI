import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../models/food_item.dart';

class SearchResultRow extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  const SearchResultRow({
    super.key,
    required this.item,
    required this.onAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (item.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.desc,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Add',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
