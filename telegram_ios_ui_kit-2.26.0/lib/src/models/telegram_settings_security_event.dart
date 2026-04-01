import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsSecurityEvent {
  const TelegramSettingsSecurityEvent({
    required this.id,
    required this.title,
    required this.timeLabel,
    this.subtitle,
    this.icon = CupertinoIcons.shield_fill,
    this.highRisk = false,
  });

  final String id;
  final String title;
  final String timeLabel;
  final String? subtitle;
  final IconData icon;
  final bool highRisk;

  TelegramSettingsSecurityEvent copyWith({
    String? id,
    String? title,
    String? timeLabel,
    String? subtitle,
    IconData? icon,
    bool? highRisk,
  }) {
    return TelegramSettingsSecurityEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      timeLabel: timeLabel ?? this.timeLabel,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      highRisk: highRisk ?? this.highRisk,
    );
  }
}
