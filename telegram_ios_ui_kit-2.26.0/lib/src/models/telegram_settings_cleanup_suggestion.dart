import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsCleanupSuggestion {
  const TelegramSettingsCleanupSuggestion({
    required this.id,
    required this.title,
    required this.sizeLabel,
    this.subtitle,
    this.icon = CupertinoIcons.delete_solid,
    this.destructive = false,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String sizeLabel;
  final String? subtitle;
  final IconData icon;
  final bool destructive;
  final bool enabled;

  TelegramSettingsCleanupSuggestion copyWith({
    String? id,
    String? title,
    String? sizeLabel,
    String? subtitle,
    IconData? icon,
    bool? destructive,
    bool? enabled,
  }) {
    return TelegramSettingsCleanupSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
    );
  }
}
