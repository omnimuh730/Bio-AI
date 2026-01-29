import 'package:flutter/material.dart';
import '../../capture/models/food_item.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

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
