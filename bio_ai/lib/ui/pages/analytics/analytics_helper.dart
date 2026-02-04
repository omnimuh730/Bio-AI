import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/analytics/analytics_state.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_history_edit_modal.dart';

void showAnalyticsToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1200),
    ),
  );
}

void openHistoryEditModal(
  BuildContext context,
  AnalyticsHistoryEntry entry,
  VoidCallback onShowToast,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AnalyticsHistoryEditModal(
        entry: entry,
        onSave: () {
          Navigator.pop(context);
          onShowToast();
        },
      );
    },
  );
}
