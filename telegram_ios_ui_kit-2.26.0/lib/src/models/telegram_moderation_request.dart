import 'package:flutter/material.dart';

@immutable
class TelegramModerationRequest {
  const TelegramModerationRequest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.pendingCount = 0,
    this.highPriority = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String timeLabel;
  final int pendingCount;
  final bool highPriority;
}
