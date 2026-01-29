import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsSelectableChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const SettingsSelectableChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<SettingsSelectableChip> createState() => _SettingsSelectableChipState();
}

class _SettingsSelectableChipState extends State<SettingsSelectableChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _selected = !_selected);
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selected ? const Color(0x1A4B7BFF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected ? AppColors.accentBlue : Colors.transparent,
          ),
        ),
        child: Text(
          widget.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: _selected ? AppColors.accentBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
