import 'package:flutter/material.dart';

@immutable
class TelegramChatWallpaper {
  const TelegramChatWallpaper.solid({
    required this.primaryColor,
    this.patternColor,
  }) : secondaryColor = null;

  const TelegramChatWallpaper.gradient({
    required this.primaryColor,
    required this.secondaryColor,
    this.patternColor,
  });

  final Color primaryColor;
  final Color? secondaryColor;
  final Color? patternColor;

  bool get isGradient => secondaryColor != null;
}
