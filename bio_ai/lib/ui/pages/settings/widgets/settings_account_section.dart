import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'settings_account_row.dart';
import 'settings_card_container.dart';
import 'settings_divider.dart';
import 'settings_section_label.dart';

class SettingsAccountSection extends StatelessWidget {
  final VoidCallback onOnboarding;
  final VoidCallback onManageSubscription;
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;

  const SettingsAccountSection({
    super.key,
    required this.onOnboarding,
    required this.onManageSubscription,
    required this.onExportData,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Account'),
        SettingsCardContainer(
          children: [
            SettingsAccountRow(
              label: 'Revisit Onboarding',
              icon: Icons.list_alt_outlined,
              onTap: onOnboarding,
            ),
            const SettingsDivider(),
            SettingsAccountRow(
              label: 'Manage Subscription',
              icon: Icons.workspace_premium_outlined,
              onTap: onManageSubscription,
              color: const Color(0xFFF59E0B),
            ),
            const SettingsDivider(),
            SettingsAccountRow(
              label: 'Export Data',
              icon: Icons.file_download_outlined,
              onTap: onExportData,
            ),
            const SettingsDivider(),
            SettingsAccountRow(
              label: 'Delete Account',
              icon: Icons.delete_outline,
              onTap: onDeleteAccount,
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
