import 'package:flutter/material.dart';

@immutable
class TelegramContact {
  const TelegramContact({
    required this.id,
    required this.name,
    this.subtitle,
    this.avatarImage,
    this.avatarFallback = '',
    this.isOnline = false,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final String? subtitle;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final bool isOnline;
  final bool isVerified;
}
