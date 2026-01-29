import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../models/food_item.dart';
import 'search_result_row.dart';

class CaptureSearchOverlay extends StatelessWidget {
  final bool open;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClose;
  final VoidCallback onAddCaffeine;
  final VoidCallback onAddAlcohol;
  final List<FoodItem> results;
  final bool isSearching;
  final ValueChanged<FoodItem> onAddItem;
  final ValueChanged<FoodItem>? onTapItem;
  final VoidCallback onCreateCustom;

  const CaptureSearchOverlay({
    super.key,
    required this.open,
    required this.controller,
    required this.onQueryChanged,
    required this.onClose,
    required this.onAddCaffeine,
    required this.onAddAlcohol,
    required this.results,
    required this.isSearching,
    required this.onAddItem,
    this.onTapItem,
    required this.onCreateCustom,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: open ? 1 : 0,
      child: IgnorePointer(
        ignoring: !open,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: controller,
                        onChanged: onQueryChanged,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search foods',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _iconButton(Icons.close, onClose),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _impactChip(
                    'Caffeine',
                    const Color(0xFFF59E0B),
                    onAddCaffeine,
                  ),
                  const SizedBox(width: 8),
                  _impactChip('Alcohol', const Color(0xFF8B5CF6), onAddAlcohol),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : results.isNotEmpty
                    ? ListView(
                        children: results
                            .map(
                              (item) => SearchResultRow(
                                item: item,
                                onAdd: () => onAddItem(item),
                                onTap: onTapItem == null
                                    ? null
                                    : () => onTapItem!(item),
                              ),
                            )
                            .toList(),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No results found.',
                              style: AppTextStyles.overline,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: onCreateCustom,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textMain,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Create Custom Food',
                                style: AppTextStyles.overline,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _impactChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: AppColors.textMain),
      ),
    );
  }
}
