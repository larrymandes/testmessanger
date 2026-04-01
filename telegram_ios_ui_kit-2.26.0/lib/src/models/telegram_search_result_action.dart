import 'package:flutter/material.dart';

@immutable
class TelegramSearchResultAction {
  const TelegramSearchResultAction({
    required this.id,
    required this.label,
    this.icon,
    this.destructive = false,
    this.enabled = true,
    this.badgeLabel,
  });

  final String id;
  final String label;
  final IconData? icon;
  final bool destructive;
  final bool enabled;
  final String? badgeLabel;

  TelegramSearchResultAction copyWith({
    String? id,
    String? label,
    IconData? icon,
    bool? destructive,
    bool? enabled,
    String? badgeLabel,
  }) {
    return TelegramSearchResultAction(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
      badgeLabel: badgeLabel ?? this.badgeLabel,
    );
  }
}
