import 'package:flutter/material.dart';

@immutable
class TelegramTimelineEvent {
  const TelegramTimelineEvent({
    required this.id,
    required this.title,
    required this.timeLabel,
    this.subtitle,
    this.completed = false,
    this.current = false,
    this.accentColor,
  });

  final String id;
  final String title;
  final String timeLabel;
  final String? subtitle;
  final bool completed;
  final bool current;
  final Color? accentColor;
}
