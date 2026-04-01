import 'package:flutter/material.dart';

@immutable
class TelegramMediaItem {
  const TelegramMediaItem({
    required this.id,
    this.image,
    this.label,
    this.isVideo = false,
    this.durationLabel,
  });

  final String id;
  final ImageProvider<Object>? image;
  final String? label;
  final bool isVideo;
  final String? durationLabel;
}
