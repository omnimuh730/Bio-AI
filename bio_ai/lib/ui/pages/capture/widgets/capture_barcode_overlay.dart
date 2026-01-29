import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/food_item.dart';

class CaptureBarcodeOverlay extends StatelessWidget {
  final bool open;
  final bool found;
  final FoodItem item;
  final VoidCallback onAdd;
  final VoidCallback onClose;
  final VoidCallback onNotFound;

  const CaptureBarcodeOverlay({
    super.key,
    required this.open,
    required this.found,
    required this.item,
    required this.onAdd,
    required this.onClose,
    required this.onNotFound,
  });

  @override
  Widget build(BuildContext context) {
    if (!open) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 240,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            found ? 'Barcode detected' : 'Scanning barcode...',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 12),
          if (found)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.cals} kcal - ${item.protein}g Protein - ${item.fat}g Fat',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textMain,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Item',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onNotFound,
            child: Text(
              'Barcode not found',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: AppColors.textMain,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
