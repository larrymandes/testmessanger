import 'package:flutter/material.dart';

@immutable
class TelegramSearchAlert {
  const TelegramSearchAlert({
    required this.id,
    required this.label,
    required this.query,
    this.scopeLabel,
    this.triggerLabel,
    this.deliveryLabel,
    this.icon,
    this.enabled = true,
    this.unreadCount = 0,
  });

  final String id;
  final String label;
  final String query;
  final String? scopeLabel;
  final String? triggerLabel;
  final String? deliveryLabel;
  final IconData? icon;
  final bool enabled;
  final int unreadCount;

  TelegramSearchAlert copyWith({
    String? id,
    String? label,
    String? query,
    String? scopeLabel,
    String? triggerLabel,
    String? deliveryLabel,
    IconData? icon,
    bool? enabled,
    int? unreadCount,
  }) {
    return TelegramSearchAlert(
      id: id ?? this.id,
      label: label ?? this.label,
      query: query ?? this.query,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      triggerLabel: triggerLabel ?? this.triggerLabel,
      deliveryLabel: deliveryLabel ?? this.deliveryLabel,
      icon: icon ?? this.icon,
      enabled: enabled ?? this.enabled,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
