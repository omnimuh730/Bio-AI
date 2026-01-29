import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class PlannerViewToggle extends StatelessWidget {
  final bool cookView;
  final VoidCallback onCook;
  final VoidCallback onEatOut;

  const PlannerViewToggle({
    super.key,
    required this.cookView,
    required this.onCook,
    required this.onEatOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                left: cookView ? 0 : width / 2,
                top: 0,
                bottom: 0,
                child: Container(
                  width: width / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _toggleOption('Cook at Home', cookView, onCook),
                  _toggleOption('Eat Out', !cookView, onEatOut),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toggleOption(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.accentBlue : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
