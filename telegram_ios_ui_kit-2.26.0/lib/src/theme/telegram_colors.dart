import 'package:flutter/material.dart';

@immutable
class TelegramColors {
  const TelegramColors({
    required this.bgColor,
    required this.secondaryBgColor,
    required this.sectionBgColor,
    required this.headerBgColor,
    required this.textColor,
    required this.subtitleTextColor,
    required this.hintColor,
    required this.linkColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.destructiveTextColor,
    required this.separatorColor,
    required this.outgoingBubbleColor,
    required this.incomingBubbleColor,
    required this.unreadBadgeColor,
    required this.onlineIndicatorColor,
  });

  final Color bgColor;
  final Color secondaryBgColor;
  final Color sectionBgColor;
  final Color headerBgColor;
  final Color textColor;
  final Color subtitleTextColor;
  final Color hintColor;
  final Color linkColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color destructiveTextColor;
  final Color separatorColor;
  final Color outgoingBubbleColor;
  final Color incomingBubbleColor;
  final Color unreadBadgeColor;
  final Color onlineIndicatorColor;

  TelegramColors copyWith({
    Color? bgColor,
    Color? secondaryBgColor,
    Color? sectionBgColor,
    Color? headerBgColor,
    Color? textColor,
    Color? subtitleTextColor,
    Color? hintColor,
    Color? linkColor,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? destructiveTextColor,
    Color? separatorColor,
    Color? outgoingBubbleColor,
    Color? incomingBubbleColor,
    Color? unreadBadgeColor,
    Color? onlineIndicatorColor,
  }) {
    return TelegramColors(
      bgColor: bgColor ?? this.bgColor,
      secondaryBgColor: secondaryBgColor ?? this.secondaryBgColor,
      sectionBgColor: sectionBgColor ?? this.sectionBgColor,
      headerBgColor: headerBgColor ?? this.headerBgColor,
      textColor: textColor ?? this.textColor,
      subtitleTextColor: subtitleTextColor ?? this.subtitleTextColor,
      hintColor: hintColor ?? this.hintColor,
      linkColor: linkColor ?? this.linkColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      destructiveTextColor: destructiveTextColor ?? this.destructiveTextColor,
      separatorColor: separatorColor ?? this.separatorColor,
      outgoingBubbleColor: outgoingBubbleColor ?? this.outgoingBubbleColor,
      incomingBubbleColor: incomingBubbleColor ?? this.incomingBubbleColor,
      unreadBadgeColor: unreadBadgeColor ?? this.unreadBadgeColor,
      onlineIndicatorColor: onlineIndicatorColor ?? this.onlineIndicatorColor,
    );
  }

  factory TelegramColors.fromTelegramTheme(
    Map<String, String> telegramTheme, {
    TelegramColors fallback = TelegramColors.light,
  }) {
    Color resolve(String key, Color fallbackColor) {
      final value =
          telegramTheme[key] ??
          telegramTheme['Telegram/$key'] ??
          telegramTheme['telegram/$key'];
      return _tryParseHexColor(value) ?? fallbackColor;
    }

    return fallback.copyWith(
      bgColor: resolve('bg_color', fallback.bgColor),
      secondaryBgColor: resolve(
        'secondary_bg_color',
        fallback.secondaryBgColor,
      ),
      sectionBgColor: resolve('section_bg_color', fallback.sectionBgColor),
      headerBgColor: resolve('header_bg_color', fallback.headerBgColor),
      textColor: resolve('text_color', fallback.textColor),
      subtitleTextColor: resolve(
        'subtitle_text_color',
        fallback.subtitleTextColor,
      ),
      hintColor: resolve('hint_color', fallback.hintColor),
      linkColor: resolve('link_color', fallback.linkColor),
      buttonColor: resolve('button_color', fallback.buttonColor),
      buttonTextColor: resolve('button_text_color', fallback.buttonTextColor),
      destructiveTextColor: resolve(
        'destructive_text_color',
        fallback.destructiveTextColor,
      ),
      separatorColor: resolve('separator_color', fallback.separatorColor),
      outgoingBubbleColor: resolve(
        'outgoing_bubble_color',
        fallback.outgoingBubbleColor,
      ),
      incomingBubbleColor: resolve(
        'incoming_bubble_color',
        fallback.incomingBubbleColor,
      ),
      unreadBadgeColor: resolve(
        'unread_badge_color',
        fallback.unreadBadgeColor,
      ),
      onlineIndicatorColor: resolve(
        'online_indicator_color',
        fallback.onlineIndicatorColor,
      ),
    );
  }

  Map<String, String> toTelegramThemeMap({bool withPrefix = false}) {
    final prefix = withPrefix ? 'Telegram/' : '';
    return {
      '${prefix}bg_color': _toHex(bgColor),
      '${prefix}secondary_bg_color': _toHex(secondaryBgColor),
      '${prefix}section_bg_color': _toHex(sectionBgColor),
      '${prefix}header_bg_color': _toHex(headerBgColor),
      '${prefix}text_color': _toHex(textColor),
      '${prefix}subtitle_text_color': _toHex(subtitleTextColor),
      '${prefix}hint_color': _toHex(hintColor),
      '${prefix}link_color': _toHex(linkColor),
      '${prefix}button_color': _toHex(buttonColor),
      '${prefix}button_text_color': _toHex(buttonTextColor),
      '${prefix}destructive_text_color': _toHex(destructiveTextColor),
      '${prefix}separator_color': _toHex(separatorColor),
      '${prefix}outgoing_bubble_color': _toHex(outgoingBubbleColor),
      '${prefix}incoming_bubble_color': _toHex(incomingBubbleColor),
      '${prefix}unread_badge_color': _toHex(unreadBadgeColor),
      '${prefix}online_indicator_color': _toHex(onlineIndicatorColor),
    };
  }

  static const TelegramColors light = TelegramColors(
    bgColor: Color(0xFFFFFFFF),
    secondaryBgColor: Color(0xFFF2F2F7),
    sectionBgColor: Color(0xFFFFFFFF),
    headerBgColor: Color(0xFFF9F9F9),
    textColor: Color(0xFF000000),
    subtitleTextColor: Color(0xFF8E8E93),
    hintColor: Color(0xFF8E8E93),
    linkColor: Color(0xFF007AFF),
    buttonColor: Color(0xFF007AFF),
    buttonTextColor: Color(0xFFFFFFFF),
    destructiveTextColor: Color(0xFFFF3B30),
    separatorColor: Color(0x332C2C2E),
    outgoingBubbleColor: Color(0xFFE1FFC7),
    incomingBubbleColor: Color(0xFFFFFFFF),
    unreadBadgeColor: Color(0xFF34C759),
    onlineIndicatorColor: Color(0xFF34C759),
  );

  static const TelegramColors dark = TelegramColors(
    bgColor: Color(0xFF000000),
    secondaryBgColor: Color(0xFF1C1C1E),
    sectionBgColor: Color(0xFF1C1C1E),
    headerBgColor: Color(0xFF111113),
    textColor: Color(0xFFFFFFFF),
    subtitleTextColor: Color(0xFF8E8E93),
    hintColor: Color(0xFF8E8E93),
    linkColor: Color(0xFF0A84FF),
    buttonColor: Color(0xFF0A84FF),
    buttonTextColor: Color(0xFFFFFFFF),
    destructiveTextColor: Color(0xFFFF453A),
    separatorColor: Color(0x52FFFFFF),
    outgoingBubbleColor: Color(0xFF2B5278),
    incomingBubbleColor: Color(0xFF1F1F1F),
    unreadBadgeColor: Color(0xFF34C759),
    onlineIndicatorColor: Color(0xFF30D158),
  );

  static Color? _tryParseHexColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final normalized = value.trim().replaceAll('#', '');
    if (normalized.length != 6 && normalized.length != 8) {
      return null;
    }
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final intValue = int.tryParse(hex, radix: 16);
    if (intValue == null) {
      return null;
    }
    return Color(intValue);
  }

  static String _toHex(Color color) {
    final red = (color.r * 255.0).round().clamp(0, 255);
    final green = (color.g * 255.0).round().clamp(0, 255);
    final blue = (color.b * 255.0).round().clamp(0, 255);
    final redHex = red.toRadixString(16).padLeft(2, '0');
    final greenHex = green.toRadixString(16).padLeft(2, '0');
    final blueHex = blue.toRadixString(16).padLeft(2, '0');
    return '#$redHex$greenHex$blueHex';
  }
}
