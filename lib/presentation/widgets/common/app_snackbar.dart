import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class AppSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = colorScheme.inverseSurface;
        textColor = colorScheme.onInverseSurface;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }
}