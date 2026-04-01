import 'package:flutter/material.dart';

import 'telegram_colors.dart';

@immutable
class TelegramThemeData {
  const TelegramThemeData({
    required this.colors,
    required this.textTheme,
    this.messageBubbleRadius = const Radius.circular(18),
    this.tileRadius = const Radius.circular(14),
    this.navBarHeight = 44,
  });

  final TelegramColors colors;
  final TextTheme textTheme;
  final Radius messageBubbleRadius;
  final Radius tileRadius;
  final double navBarHeight;

  factory TelegramThemeData.light() {
    const colors = TelegramColors.light;
    return TelegramThemeData(
      colors: colors,
      textTheme: Typography.blackCupertino,
    );
  }

  factory TelegramThemeData.dark() {
    const colors = TelegramColors.dark;
    return TelegramThemeData(
      colors: colors,
      textTheme: Typography.whiteCupertino,
    );
  }

  TelegramThemeData copyWith({
    TelegramColors? colors,
    TextTheme? textTheme,
    Radius? messageBubbleRadius,
    Radius? tileRadius,
    double? navBarHeight,
  }) {
    return TelegramThemeData(
      colors: colors ?? this.colors,
      textTheme: textTheme ?? this.textTheme,
      messageBubbleRadius: messageBubbleRadius ?? this.messageBubbleRadius,
      tileRadius: tileRadius ?? this.tileRadius,
      navBarHeight: navBarHeight ?? this.navBarHeight,
    );
  }

  ThemeData toThemeData({Brightness? brightness}) {
    final targetBrightness =
        brightness ??
        (identical(colors, TelegramColors.dark)
            ? Brightness.dark
            : Brightness.light);
    return ThemeData(
      brightness: targetBrightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.bgColor,
      textTheme: textTheme.apply(
        bodyColor: colors.textColor,
        displayColor: colors.textColor,
      ),
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: colors.linkColor,
            brightness: targetBrightness,
          ).copyWith(
            surface: colors.bgColor,
            onSurface: colors.textColor,
            primary: colors.linkColor,
            onPrimary: colors.buttonTextColor,
          ),
    );
  }
}

class TelegramTheme extends InheritedWidget {
  const TelegramTheme({super.key, required this.data, required super.child});

  final TelegramThemeData data;

  static TelegramThemeData of(BuildContext context) {
    final telegramTheme = context
        .dependOnInheritedWidgetOfExactType<TelegramTheme>();
    if (telegramTheme != null) {
      return telegramTheme.data;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? TelegramThemeData.dark()
        : TelegramThemeData.light();
  }

  @override
  bool updateShouldNotify(TelegramTheme oldWidget) => oldWidget.data != data;
}

extension TelegramThemeX on BuildContext {
  TelegramThemeData get telegramTheme => TelegramTheme.of(this);
}
