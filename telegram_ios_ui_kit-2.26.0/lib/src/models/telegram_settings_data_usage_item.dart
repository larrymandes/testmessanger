import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsDataUsageItem {
  const TelegramSettingsDataUsageItem({
    required this.id,
    required this.title,
    required this.valueLabel,
    this.subtitle,
    this.icon = CupertinoIcons.info,
    this.highlighted = false,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String valueLabel;
  final String? subtitle;
  final IconData icon;
  final bool highlighted;
  final bool enabled;

  TelegramSettingsDataUsageItem copyWith({
    String? id,
    String? title,
    String? valueLabel,
    String? subtitle,
    IconData? icon,
    bool? highlighted,
    bool? enabled,
  }) {
    return TelegramSettingsDataUsageItem(
      id: id ?? this.id,
      title: title ?? this.title,
      valueLabel: valueLabel ?? this.valueLabel,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      highlighted: highlighted ?? this.highlighted,
      enabled: enabled ?? this.enabled,
    );
  }
}
