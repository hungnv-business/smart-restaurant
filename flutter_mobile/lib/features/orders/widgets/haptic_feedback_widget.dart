import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class HapticFeedbackWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HapticType hapticType;
  final bool enableHaptic;

  const HapticFeedbackWidget({
    super.key,
    required this.child,
    this.onTap,
    this.hapticType = HapticType.light,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableHaptic || kIsWeb) {
      // Haptic feedback not supported on web
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return GestureDetector(
      onTap: () {
        _performHapticFeedback();
        onTap?.call();
      },
      child: child,
    );
  }

  void _performHapticFeedback() {
    switch (hapticType) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticType.success:
        HapticFeedback.lightImpact();
        // Double tap for success feeling
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.lightImpact();
        });
        break;
      case HapticType.error:
        HapticFeedback.heavyImpact();
        // Triple tap for error feeling
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.mediumImpact();
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          HapticFeedback.lightImpact();
        });
        break;
    }
  }
}

enum HapticType {
  light,
  medium, 
  heavy,
  selection,
  success,
  error;

  String get displayName {
    switch (this) {
      case HapticType.light:
        return 'Nhẹ';
      case HapticType.medium:
        return 'Vừa';
      case HapticType.heavy:
        return 'Mạnh';
      case HapticType.selection:
        return 'Chọn lựa';
      case HapticType.success:
        return 'Thành công';
      case HapticType.error:
        return 'Lỗi';
    }
  }
}

class HapticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final HapticType hapticType;
  final ButtonStyle? style;

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.hapticType = HapticType.light,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed != null ? () {
        _performHapticFeedback();
        onPressed!();
      } : null,
      style: style,
      child: child,
    );
  }

  void _performHapticFeedback() {
    if (!kIsWeb) {
      switch (hapticType) {
        case HapticType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          HapticFeedback.selectionClick();
          break;
        case HapticType.success:
          HapticFeedback.lightImpact();
          Future.delayed(const Duration(milliseconds: 50), () {
            HapticFeedback.lightImpact();
          });
          break;
        case HapticType.error:
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.mediumImpact();
          });
          break;
      }
    }
  }
}

class HapticIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final HapticType hapticType;
  final Color? color;
  final double? size;
  final String? tooltip;

  const HapticIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.hapticType = HapticType.light,
    this.color,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed != null ? () {
        _performHapticFeedback();
        onPressed!();
      } : null,
      icon: Icon(icon),
      color: color,
      iconSize: size,
      tooltip: tooltip,
    );
  }

  void _performHapticFeedback() {
    if (!kIsWeb) {
      switch (hapticType) {
        case HapticType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          HapticFeedback.selectionClick();
          break;
        case HapticType.success:
          HapticFeedback.lightImpact();
          Future.delayed(const Duration(milliseconds: 50), () {
            HapticFeedback.lightImpact();
          });
          break;
        case HapticType.error:
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.mediumImpact();
          });
          break;
      }
    }
  }
}

class HapticListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final HapticType hapticType;

  const HapticListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.hapticType = HapticType.light,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap != null ? () {
        _performHapticFeedback();
        onTap!();
      } : null,
    );
  }

  void _performHapticFeedback() {
    if (!kIsWeb) {
      switch (hapticType) {
        case HapticType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          HapticFeedback.selectionClick();
          break;
        case HapticType.success:
          HapticFeedback.lightImpact();
          Future.delayed(const Duration(milliseconds: 50), () {
            HapticFeedback.lightImpact();
          });
          break;
        case HapticType.error:
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.mediumImpact();
          });
          break;
      }
    }
  }
}