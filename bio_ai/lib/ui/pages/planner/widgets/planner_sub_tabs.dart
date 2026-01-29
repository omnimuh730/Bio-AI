import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';

class PlannerSubTabs extends StatelessWidget {
  final String cookTab;
  final ValueChanged<String> onTabChanged;

  const PlannerSubTabs({
    super.key,
    required this.cookTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _subTab('Pantry', cookTab == 'pantry', () => onTabChanged('pantry')),
          _subTab(
            'Leftovers',
            cookTab == 'leftovers',
            () => onTabChanged('leftovers'),
          ),
        ],
      ),
    );
  }

  Widget _subTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.textMain : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
