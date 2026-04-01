import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsSecurityAction {
  const TelegramSettingsSecurityAction({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon = CupertinoIcons.lock_fill,
    this.destructive = false,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool destructive;
  final bool enabled;

  TelegramSettingsSecurityAction copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    bool? destructive,
    bool? enabled,
  }) {
    return TelegramSettingsSecurityAction(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      destructive: destructive ?? this.destructive,
      enabled: enabled ?? this.enabled,
    );
  }
}
