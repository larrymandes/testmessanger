import 'package:flutter/material.dart';

@immutable
class TelegramSearchCommand {
  const TelegramSearchCommand({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.destructive = false,
    this.enabled = true,
    this.badgeLabel,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool destructive;
  final bool enabled;
  final String? badgeLabel;

  TelegramSearchCommand copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    bool? destructive,
    bool? enabled,
    String? badgeLabel,
  }) {
    return TelegramSearchCommand(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
      badgeLabel: badgeLabel ?? this.badgeLabel,
    );
  }
}
