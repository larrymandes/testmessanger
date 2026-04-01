import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/telegram_swipe_action.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSwipeActions extends StatefulWidget {
  const TelegramSwipeActions({
    super.key,
    required this.child,
    this.startActions = const [],
    this.endActions = const [],
    this.actionExtent = 74,
    this.openThreshold = 0.45,
    this.animationDuration = const Duration(milliseconds: 180),
    this.borderRadius,
    this.closeOnActionTap = true,
    this.onOpenChanged,
  });

  final Widget child;
  final List<TelegramSwipeAction> startActions;
  final List<TelegramSwipeAction> endActions;
  final double actionExtent;
  final double openThreshold;
  final Duration animationDuration;
  final BorderRadius? borderRadius;
  final bool closeOnActionTap;
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<TelegramSwipeActions> createState() => _TelegramSwipeActionsState();
}

class _TelegramSwipeActionsState extends State<TelegramSwipeActions> {
  double _offset = 0;
  bool _isDragging = false;
  bool _isOpen = false;

  double get _maxStartOffset =>
      widget.startActions.length * widget.actionExtent;
  double get _maxEndOffset => widget.endActions.length * widget.actionExtent;

  void _updateOffset(double nextOffset) {
    final clamped = nextOffset
        .clamp(-_maxEndOffset, _maxStartOffset)
        .toDouble();
    if (clamped == _offset) {
      return;
    }
    setState(() {
      _offset = clamped;
    });
  }

  void _setOpen(bool open) {
    if (_isOpen == open) {
      return;
    }
    _isOpen = open;
    widget.onOpenChanged?.call(open);
  }

  void _animateTo(double targetOffset) {
    setState(() {
      _isDragging = false;
      _offset = targetOffset;
    });
    _setOpen(targetOffset != 0);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) {
      setState(() {
        _isDragging = true;
      });
    }
    _updateOffset(_offset + details.delta.dx);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final hasStartActions = _maxStartOffset > 0;
    final hasEndActions = _maxEndOffset > 0;

    if (velocity > 450 && hasStartActions) {
      _animateTo(_maxStartOffset);
      return;
    }
    if (velocity < -450 && hasEndActions) {
      _animateTo(-_maxEndOffset);
      return;
    }

    if (_offset > 0 && hasStartActions) {
      final shouldOpen = _offset >= _maxStartOffset * widget.openThreshold;
      _animateTo(shouldOpen ? _maxStartOffset : 0);
      return;
    }
    if (_offset < 0 && hasEndActions) {
      final shouldOpen = _offset.abs() >= _maxEndOffset * widget.openThreshold;
      _animateTo(shouldOpen ? -_maxEndOffset : 0);
      return;
    }

    _animateTo(0);
  }

  Future<void> _handleActionTap(TelegramSwipeAction action) async {
    if (widget.closeOnActionTap) {
      _animateTo(0);
    }
    await action.onTap?.call();
  }

  Widget _buildActionButton(TelegramSwipeAction action) {
    final theme = context.telegramTheme;
    final color = action.destructive
        ? theme.colors.destructiveTextColor
        : theme.colors.linkColor;

    return SizedBox(
      width: widget.actionExtent,
      child: Material(
        color: color,
        child: InkWell(
          onTap: () => _handleActionTap(action),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (action.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: TelegramSpacing.xs),
                    child: Icon(
                      action.icon,
                      color: theme.colors.buttonTextColor,
                      size: 18,
                    ),
                  ),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.buttonTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(theme.tileRadius.x);
    final visibleStartActions = (_offset > 0 && widget.startActions.isNotEmpty)
        ? math.max(
            1,
            (_offset / widget.actionExtent).ceil().clamp(
              1,
              widget.startActions.length,
            ),
          )
        : 0;
    final visibleEndActions = (_offset < 0 && widget.endActions.isNotEmpty)
        ? math.max(
            1,
            (_offset.abs() / widget.actionExtent).ceil().clamp(
              1,
              widget.endActions.length,
            ),
          )
        : 0;

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                if (widget.startActions.isNotEmpty)
                  ...widget.startActions
                      .take(visibleStartActions)
                      .map(_buildActionButton),
                if (widget.startActions.isNotEmpty)
                  Expanded(child: ColoredBox(color: theme.colors.bgColor)),
                if (widget.endActions.isNotEmpty)
                  Expanded(child: ColoredBox(color: theme.colors.bgColor)),
                if (widget.endActions.isNotEmpty)
                  ...widget.endActions
                      .take(visibleEndActions)
                      .toList(growable: false)
                      .reversed
                      .map(_buildActionButton),
              ],
            ),
          ),
          AnimatedContainer(
            duration: _isDragging ? Duration.zero : widget.animationDuration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_offset, 0, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onHorizontalDragCancel: () => _animateTo(0),
              onTap: _isOpen ? () => _animateTo(0) : null,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
