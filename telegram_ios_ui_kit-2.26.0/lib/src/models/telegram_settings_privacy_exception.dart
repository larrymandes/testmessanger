import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsPrivacyException {
  const TelegramSettingsPrivacyException({
    required this.id,
    required this.title,
    this.subtitle,
    this.countLabel,
    this.icon,
    this.destructive = false,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? countLabel;
  final IconData? icon;
  final bool destructive;
  final bool enabled;

  TelegramSettingsPrivacyException copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? countLabel,
    IconData? icon,
    bool? destructive,
    bool? enabled,
  }) {
    return TelegramSettingsPrivacyException(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      countLabel: countLabel ?? this.countLabel,
      icon: icon ?? this.icon,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
    );
  }
}
