import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsNetworkPolicy {
  const TelegramSettingsNetworkPolicy({
    required this.id,
    required this.title,
    required this.enabled,
    this.subtitle,
    this.limitLabel,
    this.icon = CupertinoIcons.antenna_radiowaves_left_right,
    this.destructive = false,
    this.locked = false,
  });

  final String id;
  final String title;
  final bool enabled;
  final String? subtitle;
  final String? limitLabel;
  final IconData icon;
  final bool destructive;
  final bool locked;

  TelegramSettingsNetworkPolicy copyWith({
    String? id,
    String? title,
    bool? enabled,
    String? subtitle,
    String? limitLabel,
    IconData? icon,
    bool? destructive,
    bool? locked,
  }) {
    return TelegramSettingsNetworkPolicy(
      id: id ?? this.id,
      title: title ?? this.title,
      enabled: enabled ?? this.enabled,
      subtitle: subtitle ?? this.subtitle,
      limitLabel: limitLabel ?? this.limitLabel,
      icon: icon ?? this.icon,
      destructive: destructive ?? this.destructive,
      locked: locked ?? this.locked,
    );
  }
}
