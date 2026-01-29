import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import '../models/planner_leftover_item.dart';

class PlannerLeftoverCard extends StatelessWidget {
  final PlannerLeftoverItem item;
  final VoidCallback onLog;
  final VoidCallback onRemove;

  const PlannerLeftoverCard({
    super.key,
    required this.item,
    required this.onLog,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.servings} servings - ${item.note}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _leftoverButton('Log', onLog, primary: true),
              const SizedBox(width: 6),
              _leftoverButton('Remove', onRemove),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leftoverButton(
    String label,
    VoidCallback onTap, {
    bool primary = false,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: primary
            ? const Color(0xFFEEF2FF)
            : const Color(0xFFF8FAFC),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: primary ? AppColors.accentBlue : AppColors.textSecondary,
        ),
      ),
    );
  }
}
