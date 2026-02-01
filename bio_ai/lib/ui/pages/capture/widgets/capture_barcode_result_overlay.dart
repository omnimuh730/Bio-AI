import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/capture/capture_models.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_nutrition_card.dart';

class CaptureBarcodeResultOverlay extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final FoodItem? item;
  final VoidCallback onAdd;
  final VoidCallback onClose;

  const CaptureBarcodeResultOverlay({
    super.key,
    required this.foodData,
    required this.item,
    required this.onAdd,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: LiquidGlassNutritionCard(
            foodData: foodData,
            onAdd: item != null ? onAdd : () {},
            onClose: onClose,
          ),
        ),
      ),
    );
  }
}
