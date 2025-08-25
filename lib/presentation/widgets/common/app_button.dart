import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../core/services/accessibility_service.dart';

enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final String? tooltip;
  final bool autofocus;

  const AppButton({
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.width,
    this.height,
    this.semanticLabel,
    this.tooltip,
    this.autofocus = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    
    // Create semantic label for accessibility
    final buttonSemanticLabel = semanticLabel ?? 
        accessibilityService.createButtonSemanticLabel(
          action: text,
          isEnabled: onPressed != null && !isLoading,
        );
    
    Widget button = _buildButton(context);
    
    // Add accessibility enhancements
    button = Semantics(
      label: buttonSemanticLabel,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: button,
    );
    
    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    if (isExpanded) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    } else if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildButton(BuildContext context) {
    final content = _buildContent(context);
    
    switch (type) {
      case AppButtonType.primary:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          autofocus: autofocus,
          child: content,
        );
      case AppButtonType.secondary:
        return FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          autofocus: autofocus,
          child: content,
        );
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          autofocus: autofocus,
          child: content,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          autofocus: autofocus,
          child: content,
        );
    }
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getContentColor(context),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppTheme.spacingSm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  Color _getContentColor(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case AppButtonType.secondary:
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case AppButtonType.outlined:
        return Theme.of(context).colorScheme.primary;
      case AppButtonType.text:
        return Theme.of(context).colorScheme.primary;
    }
  }
}