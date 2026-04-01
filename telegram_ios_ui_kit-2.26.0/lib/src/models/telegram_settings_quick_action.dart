import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsQuickAction {
  const TelegramSettingsQuickAction({
    required this.id,
    required this.label,
    required this.icon,
    this.badgeLabel,
    this.destructive = false,
    this.enabled = true,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? badgeLabel;
  final bool destructive;
  final bool enabled;

  TelegramSettingsQuickAction copyWith({
    String? id,
    String? label,
    IconData? icon,
    String? badgeLabel,
    bool? destructive,
    bool? enabled,
  }) {
    return TelegramSettingsQuickAction(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
    );
  }
}
