import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsQuietHoursPreset {
  const TelegramSettingsQuietHoursPreset({
    required this.id,
    required this.label,
    required this.timeRangeLabel,
    this.daysLabel,
    this.enabled = true,
  });

  final String id;
  final String label;
  final String timeRangeLabel;
  final String? daysLabel;
  final bool enabled;

  TelegramSettingsQuietHoursPreset copyWith({
    String? id,
    String? label,
    String? timeRangeLabel,
    String? daysLabel,
    bool? enabled,
  }) {
    return TelegramSettingsQuietHoursPreset(
      id: id ?? this.id,
      label: label ?? this.label,
      timeRangeLabel: timeRangeLabel ?? this.timeRangeLabel,
      daysLabel: daysLabel ?? this.daysLabel,
      enabled: enabled ?? this.enabled,
    );
  }
}
