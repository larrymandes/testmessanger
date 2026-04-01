import 'package:flutter/material.dart';

@immutable
class TelegramBannedMember {
  const TelegramBannedMember({
    required this.id,
    required this.name,
    required this.reasonLabel,
    required this.untilLabel,
    this.avatarImage,
    this.avatarFallback = '',
    this.restrictedBy,
    this.canAppeal = true,
  });

  final String id;
  final String name;
  final String reasonLabel;
  final String untilLabel;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final String? restrictedBy;
  final bool canAppeal;
}
