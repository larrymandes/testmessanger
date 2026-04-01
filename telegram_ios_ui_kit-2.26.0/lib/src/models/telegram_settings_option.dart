import 'package:flutter/material.dart';

@immutable
class TelegramSettingsOption {
  const TelegramSettingsOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.icon,
    this.destructive = false,
    this.enabled = true,
    this.badgeLabel,
  });

  final String id;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool destructive;
  final bool enabled;
  final String? badgeLabel;

  TelegramSettingsOption copyWith({
    String? id,
    String? label,
    String? subtitle,
    IconData? icon,
    bool? destructive,
    bool? enabled,
    String? badgeLabel,
  }) {
    return TelegramSettingsOption(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
      badgeLabel: badgeLabel ?? this.badgeLabel,
    );
  }
}
