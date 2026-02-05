import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

import 'capture_models.dart';

/// Recursively converts all nested Maps to Map<String, dynamic>
/// This is needed because JSON decoded from HTTP responses often
/// returns Map<dynamic, dynamic> which causes type errors in Dart.
Map<String, dynamic> deepConvertMap(dynamic data) {
  if (data is Map) {
    return data.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), deepConvertMap(value));
      } else if (value is List) {
        return MapEntry(key.toString(), deepConvertList(value));
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }
  return <String, dynamic>{};
}

/// Recursively converts all nested Maps in a List
List<dynamic> deepConvertList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) {
      return deepConvertMap(item);
    } else if (item is List) {
      return deepConvertList(item);
    } else {
      return item;
    }
  }).toList();
}

FoodItem? parseFatSecretFood(dynamic food) {
  try {
    final name = food['food_name'] ?? food['name'] ?? 'Unknown Food';
    final brandName = food['brand_name'] ?? '';
    final fullName = brandName.isNotEmpty ? '$brandName $name' : name;

    final description = food['food_description'] ?? food['description'] ?? '';

    // Parse nutrition from description (FatSecret format) OR from servings
    double cals = 0, protein = 0, fat = 0;

    // Try to get from servings first (barcode API format)
    final servings = food['servings'];
    if (servings != null && servings['serving'] != null) {
      final serving = servings['serving'];
      final firstServing = serving is List ? serving[0] : serving;

      if (firstServing != null) {
        cals =
            double.tryParse(firstServing['calories']?.toString() ?? '0') ?? 0;
        protein =
            double.tryParse(firstServing['protein']?.toString() ?? '0') ?? 0;
        fat = double.tryParse(firstServing['fat']?.toString() ?? '0') ?? 0;
      }
    }

    // Fallback: parse from description if servings didn't work
    if (cals == 0 && description.isNotEmpty) {
      final calMatch = RegExp(r'(\d+\.?\d*)\s*kcal').firstMatch(description);
      final proteinMatch = RegExp(
        r'Protein:\s*(\d+\.?\d*)g',
      ).firstMatch(description);
      final fatMatch = RegExp(r'Fat:\s*(\d+\.?\d*)g').firstMatch(description);

      if (calMatch != null) cals = double.tryParse(calMatch.group(1)!) ?? 0;
      if (proteinMatch != null) {
        protein = double.tryParse(proteinMatch.group(1)!) ?? 0;
      }
      if (fatMatch != null) {
        fat = double.tryParse(fatMatch.group(1)!) ?? 0;
      }
    }

    return FoodItem(
      name: fullName,
      desc: description,
      cals: cals,
      protein: protein,
      fat: fat,
      image: food['food_image']?.toString() ?? food['image']?.toString() ?? '',
    );
  } catch (e) {
    return null;
  }
}

Future<void> showLogDialog(
  BuildContext context, {
  required VoidCallback onViewDiary,
  required VoidCallback onClose,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Meal Logged', style: AppTextStyles.dmSans16Bold),
            const SizedBox(height: 12),
            Text(
              'Your meal was added to the diary.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onViewDiary();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('View Diary', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onClose();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: AppColors.textMain,
                    ),
                    child: Text('Back Home', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<FoodItem?> showCustomFoodDialog(
  BuildContext context, {
  String initialName = '',
}) {
  final nameController = TextEditingController(text: initialName);
  final calController = TextEditingController();
  final proteinController = TextEditingController();
  final fatController = TextEditingController();

  return showDialog<FoodItem>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Custom Food',
                      style: AppTextStyles.dmSans16Bold,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _modalInput('Name', nameController),
                _modalInput(
                  'Calories',
                  calController,
                  keyboard: TextInputType.number,
                ),
                _modalInput(
                  'Protein',
                  proteinController,
                  keyboard: TextInputType.number,
                ),
                _modalInput(
                  'Fat',
                  fatController,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final calories =
                              double.tryParse(calController.text) ?? 0;
                          if (name.isEmpty || calories <= 0) return;
                          final custom = FoodItem(
                            name: name,
                            desc: 'Custom - ${calories.round()} kcal',
                            cals: calories,
                            protein:
                                double.tryParse(proteinController.text) ?? 0,
                            fat: double.tryParse(fatController.text) ?? 0,
                            image:
                                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=150&q=80',
                          );
                          Navigator.pop(context, custom);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textMain,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Save', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.textMain,
                        ),
                        child: Text('Cancel', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Widget _modalInput(
  String label,
  TextEditingController controller, {
  TextInputType keyboard = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    ),
  );
}
