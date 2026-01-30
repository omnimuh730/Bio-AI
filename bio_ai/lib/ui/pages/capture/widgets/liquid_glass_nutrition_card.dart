import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

class LiquidGlassNutritionCard extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final VoidCallback onAdd;
  final VoidCallback onClose;

  const LiquidGlassNutritionCard({
    super.key,
    required this.foodData,
    required this.onAdd,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final food = foodData;
    final servings = food['servings']?['serving'] as List?;
    final primaryServing = servings?.first ?? {};

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Product name and brand
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (food['brand_name'] != null)
                            Text(
                              food['brand_name'],
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            food['food_name'] ?? 'Unknown Product',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (food['food_type'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                food['food_type'],
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Serving info
                    if (primaryServing.isNotEmpty) ...[
                      _buildGlassContainer(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Serving Size',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white60,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    primaryServing['serving_description'] ??
                                        'N/A',
                                    style: AppTextStyles.label.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Main macros
                    Text(
                      'Nutrition Facts',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Big calorie card
                    _buildGlassContainer(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.3),
                          Colors.deepOrange.withValues(alpha: 0.2),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CALORIES',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  '${primaryServing['calories'] ?? 0}',
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Macros row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroCard(
                            'Protein',
                            primaryServing['protein'] ?? 0,
                            'g',
                            Icons.fitness_center,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMacroCard(
                            'Carbs',
                            primaryServing['carbohydrate'] ?? 0,
                            'g',
                            Icons.grain,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMacroCard(
                            'Fat',
                            primaryServing['fat'] ?? 0,
                            'g',
                            Icons.water_drop,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Detailed nutrients
                    Text(
                      'Detailed Breakdown',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildGlassContainer(
                      child: Column(
                        children: _buildAllNutrients(context, primaryServing),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF667EEA,
                            ).withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add to My Foods',
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, Gradient? gradient}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient:
                gradient ??
                LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMacroCard(
    String label,
    dynamic value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return _buildGlassContainer(
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value ?? 0}$unit',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, dynamic value, String unit) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Text(
            '$value$unit',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllNutrients(
    BuildContext context,
    Map<String, dynamic> serving,
  ) {
    final List<Widget> widgets = [];

    // Keys already shown in main UI
    final excludeKeys = {
      'calories',
      'protein',
      'carbohydrate',
      'fat',
      'serving_description',
      'serving_id',
      'serving_url',
      'number_of_units',
    };

    // Iterate over every key in the serving and show it dynamically
    serving.forEach((key, value) {
      if (excludeKeys.contains(key)) return;

      final label = key
          .split('_')
          .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w,
          )
          .join(' ');

      String displayValue;
      if (value == null) {
        displayValue = '';
      } else if (value is List) {
        // Concise summary for lists
        displayValue = 'List (${value.length})';
      } else if (value is Map) {
        displayValue = 'Object';
      } else {
        displayValue = value.toString();
      }

      widgets.add(_buildNutrientRow(label, displayValue, ''));
    });

    return widgets.isEmpty
        ? [
            const Text(
              'No detailed nutrition data available',
              style: TextStyle(color: Colors.white70),
            ),
          ]
        : widgets;
  }
}
