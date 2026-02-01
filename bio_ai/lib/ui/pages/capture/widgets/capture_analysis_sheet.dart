import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/pages/capture/capture_models.dart';

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
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Text(
                      'Edit',
                      style: AppTextStyles.labelSmall.copyWith(
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
                          style: AppTextStyles.labelSmall.copyWith(
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
                          style: AppTextStyles.heading3.copyWith(
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
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentBlue),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onPortionChanged;

  const FoodCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onPortionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                PortionSelector(
                  selectedIndex: item.portionIndex,
                  onChanged: onPortionChanged,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

class PortionSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PortionSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final slot = width / 3;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: slot * selectedIndex,
                top: 0,
                bottom: 0,
                child: Container(
                  width: slot,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textMain,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                children: [
                  _portionOption('Small', 0),
                  _portionOption('Med', 1),
                  _portionOption('Large', 2),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _portionOption(String label, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Container(
          alignment: Alignment.center,
          height: 32,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
