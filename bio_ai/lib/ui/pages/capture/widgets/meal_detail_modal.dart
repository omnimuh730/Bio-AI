import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/pages/capture/capture_models.dart';

class MealDetailModal extends StatefulWidget {
  final FoodItem item;
  final Future<Map<String, dynamic>?> Function(String) loadFatSecret;

  const MealDetailModal({
    super.key,
    required this.item,
    required this.loadFatSecret,
  });

  @override
  State<MealDetailModal> createState() => _MealDetailModalState();
}

class _MealDetailModalState extends State<MealDetailModal> {
  Map<String, dynamic>? fatRaw;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final raw = widget.item.metadata?['rawMeal'] as Map<String, dynamic>?;

    return AlertDialog(
      title: Text(widget.item.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item.image.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 160,
                child: Image.network(widget.item.image, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            if (raw != null) ...[
              Text(
                'Category: ${raw['strCategory'] ?? '-'}',
                style: AppTextStyles.overline,
              ),
              const SizedBox(height: 4),
              Text(
                'Area: ${raw['strArea'] ?? '-'}',
                style: AppTextStyles.overline,
              ),
              const SizedBox(height: 8),
              Text('Instructions', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(raw['strInstructions'] ?? '-', style: AppTextStyles.body),
              const SizedBox(height: 12),
            ],
            if (fatRaw != null) ...[_buildFatSecretSection(fatRaw!)],
            if (fatRaw == null && !loading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => loading = true);
                    final f = await widget.loadFatSecret(widget.item.name);
                    setState(() {
                      fatRaw = f;
                      loading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Load Nutrition Details'),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(widget.item);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildFatSecretSection(Map<String, dynamic> fat) {
    final servings = fat['servings'] != null
        ? fat['servings']['serving'] as List
        : null;
    final attrs = fat['food_attributes'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('Nutrition Facts', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        if (servings != null && servings.isNotEmpty) ...[
          Text(
            'Serving: ${servings[0]['serving_description'] ?? '-'}',
            style: AppTextStyles.overline,
          ),
          const SizedBox(height: 8),
          Text(
            'Calories: ${servings[0]['calories'] ?? '-'} kcal',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
        ],
        if (attrs != null) ...[
          Text('Attributes', style: AppTextStyles.label),
          const SizedBox(height: 6),
          if (attrs['allergens'] != null &&
              attrs['allergens']['allergen'] != null)
            Wrap(
              spacing: 8,
              children: List<Widget>.from(
                (attrs['allergens']['allergen'] as List).map((a) {
                  final name = a['name'] ?? '';
                  final value = a['value'] ?? '0';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (value == '0')
                          ? const Color(0xFFDFF7E0)
                          : const Color(0xFFFFEDEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (value == '0') ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: (value == '0') ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(name, style: AppTextStyles.labelSmall),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ],
    );
  }
}
