import 'package:flutter/material.dart';

@immutable
class TelegramAdminMember {
  const TelegramAdminMember({
    required this.id,
    required this.name,
    required this.roleLabel,
    this.avatarImage,
    this.avatarFallback = '',
    this.isOnline = false,
    this.isBot = false,
    this.isOwner = false,
    this.lastSeenLabel,
    this.pendingReports = 0,
  });

  final String id;
  final String name;
  final String roleLabel;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final bool isOnline;
  final bool isBot;
  final bool isOwner;
  final String? lastSeenLabel;
  final int pendingReports;
}
