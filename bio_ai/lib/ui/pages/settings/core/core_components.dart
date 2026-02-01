import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

class SettingsSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.dmSans16Bold),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          SettingsToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class SettingsToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsToggleSwitch({super.key, this.value = false, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.accentGreen : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}

class SettingsSectionLabel extends StatelessWidget {
  final String label;

  const SettingsSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class SettingsCardContainer extends StatelessWidget {
  final List<Widget> children;

  const SettingsCardContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }
}

class SettingsActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const SettingsActionRow({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class SettingsUnitToggle extends StatelessWidget {
  final bool metricUnits;
  final ValueChanged<bool> onChanged;

  const SettingsUnitToggle({
    super.key,
    required this.metricUnits,
    required this.onChanged,
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTextStyles.button),
        ),
      ),
    );
  }
}

class SettingsUnitCard extends StatelessWidget {
  final String label;
  final String value;

  const SettingsUnitCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class SettingsUnitPreview extends StatelessWidget {
  final bool metricUnits;

  const SettingsUnitPreview({super.key, required this.metricUnits});

  @override
  Widget build(BuildContext context) {
    final weight = metricUnits ? '72 kg' : '159 lb';
    final height = metricUnits ? '172 cm' : '5 ft 8 in';
    final water = metricUnits ? '2,500 ml' : '84 oz';
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      children: [
        SettingsUnitCard(label: 'Weight', value: weight),
        SettingsUnitCard(label: 'Height', value: height),
        SettingsUnitCard(label: 'Water Goal', value: water),
        const SettingsUnitCard(label: 'Active Burn', value: '620 kcal'),
      ],
    );
  }
}

class SettingsAccountRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const SettingsAccountRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Icon(
                icon,
                size: 18,
                color: color ?? AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color ?? AppColors.textMain,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class SettingsGoalOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SettingsGoalOption({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.accentBlue : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0x0D4B7BFF) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.dmSans14SemiBold),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.accentBlue
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: AppColors.accentBlue,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsInputField extends StatelessWidget {
  final String label;
  final String hint;

  const SettingsInputField({
    super.key,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelSmall,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsModalShell extends StatelessWidget {
  final String title;
  final Widget child;
  final String primaryText;
  final VoidCallback onPrimary;
  final Color primaryColor;
  final bool primaryEnabled;

  const SettingsModalShell({
    super.key,
    required this.title,
    required this.child,
    required this.primaryText,
    required this.onPrimary,
    this.primaryColor = const Color(0xFF2563EB),
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: primaryEnabled ? onPrimary : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      primaryText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: AppColors.textMain,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
                  style: AppTextStyles.dmSans14SemiBold.copyWith(
                    color: selected ? AppColors.accentBlue : AppColors.textMain,
                  ),
                ),
                Text(
                  entry.key == 'pro-monthly'
                      ? '\$9.99'
                      : entry.key == 'pro-annual'
                      ? '\$79'
                      : '5 scans/week',
                  style: AppTextStyles.labelSmall.copyWith(
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

class SettingsGoalItem {
  final String title;
  final bool selected;

  const SettingsGoalItem({required this.title, required this.selected});
}
