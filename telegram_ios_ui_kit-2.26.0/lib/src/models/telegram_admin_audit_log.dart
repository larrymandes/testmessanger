import 'package:flutter/material.dart';

@immutable
class TelegramAdminAuditLog {
  const TelegramAdminAuditLog({
    required this.id,
    required this.actorName,
    required this.actionLabel,
    required this.timeLabel,
    this.targetLabel,
    this.icon,
    this.highPriority = false,
  });

  final String id;
  final String actorName;
  final String actionLabel;
  final String timeLabel;
  final String? targetLabel;
  final IconData? icon;
  final bool highPriority;
}
