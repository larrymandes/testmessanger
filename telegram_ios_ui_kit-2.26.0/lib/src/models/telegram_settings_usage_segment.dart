import 'package:flutter/material.dart';

@immutable
class TelegramSettingsUsageSegment {
  const TelegramSettingsUsageSegment({
    required this.id,
    required this.label,
    required this.ratio,
    required this.valueLabel,
    this.color,
  }) : assert(ratio >= 0 && ratio <= 1);

  final String id;
  final String label;
  final double ratio;
  final String valueLabel;
  final Color? color;

  TelegramSettingsUsageSegment copyWith({
    String? id,
    String? label,
    double? ratio,
    String? valueLabel,
    Color? color,
  }) {
    return TelegramSettingsUsageSegment(
      id: id ?? this.id,
      label: label ?? this.label,
      ratio: ratio ?? this.ratio,
      valueLabel: valueLabel ?? this.valueLabel,
      color: color ?? this.color,
    );
  }
}
