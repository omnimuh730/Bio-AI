import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';

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
