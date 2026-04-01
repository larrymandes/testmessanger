import 'package:flutter/material.dart';

@immutable
class TelegramSettingsShortcut {
  const TelegramSettingsShortcut({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.badgeLabel,
    this.destructive = false,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? badgeLabel;
  final bool destructive;
  final bool enabled;

  TelegramSettingsShortcut copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    String? badgeLabel,
    bool? destructive,
    bool? enabled,
  }) {
    return TelegramSettingsShortcut(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
    );
  }
}
