import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsSyncStatusItem {
  const TelegramSettingsSyncStatusItem({
    required this.id,
    required this.title,
    required this.statusLabel,
    this.subtitle,
    this.icon = CupertinoIcons.arrow_2_circlepath,
    this.warning = false,
    this.inProgress = false,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String statusLabel;
  final String? subtitle;
  final IconData icon;
  final bool warning;
  final bool inProgress;
  final bool enabled;

  TelegramSettingsSyncStatusItem copyWith({
    String? id,
    String? title,
    String? statusLabel,
    String? subtitle,
    IconData? icon,
    bool? warning,
    bool? inProgress,
    bool? enabled,
  }) {
    return TelegramSettingsSyncStatusItem(
      id: id ?? this.id,
      title: title ?? this.title,
      statusLabel: statusLabel ?? this.statusLabel,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      warning: warning ?? this.warning,
      inProgress: inProgress ?? this.inProgress,
      enabled: enabled ?? this.enabled,
    );
  }
}
