import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsConnectedApp {
  const TelegramSettingsConnectedApp({
    required this.id,
    required this.name,
    required this.lastUsedLabel,
    this.subtitle,
    this.icon = CupertinoIcons.app_badge,
    this.verified = false,
    this.warningCount = 0,
    this.enabled = true,
  });

  final String id;
  final String name;
  final String lastUsedLabel;
  final String? subtitle;
  final IconData icon;
  final bool verified;
  final int warningCount;
  final bool enabled;

  TelegramSettingsConnectedApp copyWith({
    String? id,
    String? name,
    String? lastUsedLabel,
    String? subtitle,
    IconData? icon,
    bool? verified,
    int? warningCount,
    bool? enabled,
  }) {
    return TelegramSettingsConnectedApp(
      id: id ?? this.id,
      name: name ?? this.name,
      lastUsedLabel: lastUsedLabel ?? this.lastUsedLabel,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      verified: verified ?? this.verified,
      warningCount: warningCount ?? this.warningCount,
      enabled: enabled ?? this.enabled,
    );
  }
}
