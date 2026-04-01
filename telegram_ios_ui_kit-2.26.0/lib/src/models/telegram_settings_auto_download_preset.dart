import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsAutoDownloadPreset {
  const TelegramSettingsAutoDownloadPreset({
    required this.id,
    required this.label,
    required this.mediaLimitLabel,
    this.description,
    this.enabled = true,
  });

  final String id;
  final String label;
  final String mediaLimitLabel;
  final String? description;
  final bool enabled;

  TelegramSettingsAutoDownloadPreset copyWith({
    String? id,
    String? label,
    String? mediaLimitLabel,
    String? description,
    bool? enabled,
  }) {
    return TelegramSettingsAutoDownloadPreset(
      id: id ?? this.id,
      label: label ?? this.label,
      mediaLimitLabel: mediaLimitLabel ?? this.mediaLimitLabel,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }
}
