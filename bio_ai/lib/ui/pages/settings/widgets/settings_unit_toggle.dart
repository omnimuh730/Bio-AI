import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsUnitToggle extends StatelessWidget {
  final bool metricUnits;
  final ValueChanged<bool> onChanged;

  const SettingsUnitToggle({super.key, required this.metricUnits, required this.onChanged});

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
          _toggleButton('Metric', metricUnits),
          _toggleButton('Imperial', !metricUnits),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(label == 'Metric'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.kTextMain : AppColors.kTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
