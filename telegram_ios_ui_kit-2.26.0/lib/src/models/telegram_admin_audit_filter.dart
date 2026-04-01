import 'package:flutter/material.dart';

@immutable
class TelegramAdminAuditFilter {
  const TelegramAdminAuditFilter({
    required this.id,
    required this.label,
    this.count = 0,
    this.icon,
  });

  final String id;
  final String label;
  final int count;
  final IconData? icon;
}
