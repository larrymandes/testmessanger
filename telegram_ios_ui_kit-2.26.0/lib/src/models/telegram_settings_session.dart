import 'package:flutter/cupertino.dart';

@immutable
class TelegramSettingsSession {
  const TelegramSettingsSession({
    required this.id,
    required this.deviceName,
    required this.platformLabel,
    required this.lastActiveLabel,
    this.locationLabel,
    this.icon = CupertinoIcons.device_phone_portrait,
    this.isCurrentDevice = false,
    this.isOnline = false,
  });

  final String id;
  final String deviceName;
  final String platformLabel;
  final String lastActiveLabel;
  final String? locationLabel;
  final IconData icon;
  final bool isCurrentDevice;
  final bool isOnline;

  TelegramSettingsSession copyWith({
    String? id,
    String? deviceName,
    String? platformLabel,
    String? lastActiveLabel,
    String? locationLabel,
    IconData? icon,
    bool? isCurrentDevice,
    bool? isOnline,
  }) {
    return TelegramSettingsSession(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      platformLabel: platformLabel ?? this.platformLabel,
      lastActiveLabel: lastActiveLabel ?? this.lastActiveLabel,
      locationLabel: locationLabel ?? this.locationLabel,
      icon: icon ?? this.icon,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
