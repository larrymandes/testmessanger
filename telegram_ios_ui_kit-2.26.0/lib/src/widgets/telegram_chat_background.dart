import 'package:flutter/material.dart';

import '../models/telegram_chat_wallpaper.dart';
import '../theme/telegram_theme.dart';

class TelegramChatBackground extends StatelessWidget {
  const TelegramChatBackground({
    super.key,
    required this.child,
    this.wallpaper,
    this.showPattern = true,
    this.opacity = 0.24,
    this.patternSpacing = 38,
    this.patternDotRadius = 1.2,
  });

  final Widget child;
  final TelegramChatWallpaper? wallpaper;
  final bool showPattern;
  final double opacity;
  final double patternSpacing;
  final double patternDotRadius;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final startColor = wallpaper?.primaryColor ?? theme.colors.bgColor;
    final endColor = wallpaper?.secondaryColor ?? theme.colors.secondaryBgColor;
    final patternColor =
        wallpaper?.patternColor ??
        theme.colors.separatorColor.withValues(alpha: opacity);

    final base = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );

    if (!showPattern) {
      return base;
    }

    return CustomPaint(
      painter: _TelegramChatPatternPainter(
        color: patternColor,
        spacing: patternSpacing,
        dotRadius: patternDotRadius,
      ),
      child: base,
    );
  }
}

class _TelegramChatPatternPainter extends CustomPainter {
  const _TelegramChatPatternPainter({
    required this.color,
    required this.spacing,
    required this.dotRadius,
  });

  final Color color;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final startY = spacing / 2 - 1;
    final startX = spacing / 2 - 3;
    for (double y = startY; y < size.height; y += spacing) {
      for (double x = startX; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TelegramChatPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.dotRadius != dotRadius;
  }
}
