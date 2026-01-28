import 'package:flutter/material.dart';

class AnalyticsHistoryEntry {
  final String hour;
  final String meridiem;
  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;

  const AnalyticsHistoryEntry(
    this.hour,
    this.meridiem,
    this.title,
    this.subtitle,
    this.value,
    this.valueColor,
  );
}
