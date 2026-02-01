import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'planner_view_toggle.dart';

class PlannerHeader extends StatelessWidget {
  final bool cookView;
  final VoidCallback onCook;
  final VoidCallback onEatOut;

  const PlannerHeader({
    super.key,
    required this.cookView,
    required this.onCook,
    required this.onEatOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Smart Planner', style: AppTextStyles.heading1),
              const Icon(
                Icons.calendar_month,
                size: 20,
                color: AppColors.accentBlue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          PlannerViewToggle(
            cookView: cookView,
            onCook: onCook,
            onEatOut: onEatOut,
          ),
        ],
      ),
    );
  }
}
