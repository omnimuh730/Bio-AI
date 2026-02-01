import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/core/localization/app_localizations.dart';
import 'package:bio_ai/core/theme/app_spacing_borders_shadows.dart';
import 'package:bio_ai/data/providers/data_provider.dart';

class DailyProgressCard extends StatelessWidget {
  final DataProvider? dataProvider;

  const DailyProgressCard({super.key, this.dataProvider});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final metrics = dataProvider?.todayMetrics;
    final goals = dataProvider?.dailyGoals;

    final caloriesRemaining =
        (goals?.caloriesTarget ?? 2000) - (metrics?.calories ?? 1850);
    final caloriesProgress =
        (metrics?.calories ?? 1850) / (goals?.caloriesTarget ?? 2000);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppBorderRadius.bXl,
        boxShadow: AppShadows.shadow2,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: caloriesProgress,
                    strokeWidth: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: AppColors.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$caloriesRemaining', style: AppTextStyles.subtitle),
                    Text(
                      localizations.calories.toUpperCase(),
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                MacroRow(
                  label: localizations.protein,
                  val:
                      '${metrics?.protein.toStringAsFixed(0) ?? '0'}g / ${goals?.proteinTarget.toStringAsFixed(0) ?? '100'}g',
                  pct: (metrics?.protein ?? 0) / (goals?.proteinTarget ?? 100),
                  color: AppColors.accentPurple,
                ),
                const SizedBox(height: 12),
                MacroRow(
                  label: localizations.carbs,
                  val:
                      '${metrics?.carbs.toStringAsFixed(0) ?? '0'}g / ${goals?.carbsTarget.toStringAsFixed(0) ?? '250'}g',
                  pct: (metrics?.carbs ?? 0) / (goals?.carbsTarget ?? 250),
                  color: AppColors.accentGreen,
                ),
                const SizedBox(height: 12),
                MacroRow(
                  label: localizations.fat,
                  val:
                      '${metrics?.fat.toStringAsFixed(0) ?? '0'}g / ${goals?.fatTarget.toStringAsFixed(0) ?? '70'}g',
                  pct: (metrics?.fat ?? 0) / (goals?.fatTarget ?? 70),
                  color: AppColors.accentOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MacroRow extends StatelessWidget {
  final String label;
  final String val;
  final double pct;
  final Color color;

  const MacroRow({
    super.key,
    required this.label,
    required this.val,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.label),
            Text(val, style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            widthFactor: pct.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
