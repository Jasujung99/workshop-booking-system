import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final List<Widget>? actions;
  final bool barrierDismissible;

  const AppDialog({
    required this.title,
    this.content,
    this.contentWidget,
    this.actions,
    this.barrierDismissible = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: contentWidget ?? (content != null ? Text(content!) : null),
      actions: actions,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        actions: [
          AppButton(
            text: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
            type: AppButtonType.text,
          ),
          AppButton(
            text: confirmText,
            onPressed: () => Navigator.of(context).pop(true),
            type: isDangerous ? AppButtonType.primary : AppButtonType.primary,
          ),
        ],
      ),
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = '확인',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        actions: [
          AppButton(
            text: buttonText,
            onPressed: () => Navigator.of(context).pop(),
            type: AppButtonType.primary,
          ),
        ],
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = '오류',
    String buttonText = '확인',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: message,
        actions: [
          AppButton(
            text: buttonText,
            onPressed: () => Navigator.of(context).pop(),
            type: AppButtonType.primary,
          ),
        ],
      ),
    );
  }
}

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool isScrollControlled;
  final bool isDismissible;

  const AppBottomSheet({
    required this.child,
    this.title,
    this.isScrollControlled = false,
    this.isDismissible = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      builder: (context) => AppBottomSheet(
        title: title,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        child: child,
      ),
    );
  }
}