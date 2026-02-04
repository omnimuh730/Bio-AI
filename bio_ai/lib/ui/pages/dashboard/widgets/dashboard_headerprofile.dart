import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

import 'package:bio_ai/core/localization/app_localizations.dart';
import 'package:bio_ai/core/theme/app_spacing_borders_shadows.dart';
import 'package:bio_ai/data/providers/data_provider.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  final String? linkText;

  const SectionTitle(this.title, {super.key, this.onRefresh, this.linkText});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          if (onRefresh != null || linkText != null)
            GestureDetector(
              onTap: onRefresh,
              child: Text(
                linkText ?? localizations.refresh,
                style: AppTextStyles.label,
              ),
            ),
        ],
      ),
    );
  }
}

class HeaderProfile extends StatelessWidget {
  final DataProvider? dataProvider;
  final bool isSyncActive;
  final String? connectedDeviceName;

  const HeaderProfile({
    super.key,
    this.dataProvider,
    this.isSyncActive = false,
    this.connectedDeviceName,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final userName = dataProvider?.userProfile.name ?? 'Dekomori';
    final statusLabel = isSyncActive
        ? localizations.bioSyncActive
        : localizations.bioSyncInactive;
    final statusDetail =
        isSyncActive && connectedDeviceName != null && connectedDeviceName!.isNotEmpty
            ? ' · ${connectedDeviceName!}'
            : '';
    final statusColor = isSyncActive
        ? AppColors.success
        : AppColors.textLight;

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
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.shadowColor(statusColor, 8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$statusLabel$statusDetail',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSyncActive
                          ? AppTextStyles.bodySmall.color
                          : AppColors.textSecondary,
                    ),
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
            decoration: const BoxDecoration(
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
