import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing_borders_shadows.dart';
import '../../data/providers/data_provider.dart';

class HeaderProfile extends StatelessWidget {
  final DataProvider? dataProvider;

  const HeaderProfile({super.key, this.dataProvider});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Get user name from data provider or use default
    final userName = dataProvider?.userProfile.name ?? 'Dekomori';

    return Padding(
      padding: AppSpacings.contentPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.shadowColor(AppColors.success, 8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    localizations.bioSyncActive,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${localizations.hello}, $userName',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.bMd,
              boxShadow: AppShadows.shadow2,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
