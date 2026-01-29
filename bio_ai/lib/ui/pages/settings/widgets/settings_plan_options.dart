import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsPlanOptions extends StatelessWidget {
  final String selectedPlan;
  final ValueChanged<String> onPlanSelected;

  const SettingsPlanOptions({
    super.key,
    required this.selectedPlan,
    required this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = {
      'pro-monthly': 'Pro Monthly',
      'pro-annual': 'Pro Annual',
      'free': 'Free',
    };
    return Column(
      children: options.entries.map((entry) {
        final selected = selectedPlan == entry.key;
        return GestureDetector(
          onTap: () => onPlanSelected(entry.key),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.accentBlue
                    : const Color(0xFFE2E8F0),
              ),
              color: selected ? const Color(0x144B7BFF) : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.accentBlue : AppColors.textMain,
                  ),
                ),
                Text(
                  entry.key == 'pro-monthly'
                      ? '\$9.99'
                      : entry.key == 'pro-annual'
                      ? '\$79'
                      : '5 scans/week',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.accentBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
