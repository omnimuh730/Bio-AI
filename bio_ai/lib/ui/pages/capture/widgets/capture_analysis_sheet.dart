import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import '../models/food_item.dart';
import 'food_card.dart';

class CaptureAnalysisSheet extends StatelessWidget {
  final bool open;
  final bool searchOpen;
  final List<FoodItem> items;
  final double totalCals;
  final double totalProtein;
  final double totalFat;
  final bool offlineMode;
  final VoidCallback onClose;
  final VoidCallback onOpenSearch;
  final void Function(int index) onRemoveItem;
  final void Function(int index, int portionIndex) onPortionChanged;
  final VoidCallback onLog;

  const CaptureAnalysisSheet({
    super.key,
    required this.open,
    required this.searchOpen,
    required this.items,
    required this.totalCals,
    required this.totalProtein,
    required this.totalFat,
    required this.offlineMode,
    required this.onClose,
    required this.onOpenSearch,
    required this.onRemoveItem,
    required this.onPortionChanged,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: open && !searchOpen ? 0 : -height,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgBody,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analysis',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  ...items.asMap().entries.map(
                    (entry) => FoodCard(
                      item: entry.value,
                      onRemove: () => onRemoveItem(entry.key),
                      onPortionChanged: (index) =>
                          onPortionChanged(entry.key, index),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onOpenSearch,
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: AppColors.accentBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Manual Search',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _macroTag('P: ${totalProtein.round()}g'),
                            const SizedBox(width: 8),
                            _macroTag('F: ${totalFat.round()}g'),
                          ],
                        ),
                        Text(
                          '${totalCals.round()} kcal',
                          style: GoogleFonts.dmSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onLog,
                    icon: const Icon(Icons.check),
                    label: Text(
                      offlineMode ? 'Save for Later' : 'Log to Diary',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.accentBlue,
        ),
      ),
    );
  }
}
