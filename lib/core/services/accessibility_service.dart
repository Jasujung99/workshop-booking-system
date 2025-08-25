import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:logger/logger.dart';
import 'navigation_service.dart';

/// Service for managing accessibility features
class AccessibilityService {
  static final Logger _logger = Logger();
  static AccessibilityService? _instance;
  
  static AccessibilityService get instance {
    _instance ??= AccessibilityService._();
    return _instance!;
  }

  AccessibilityService._();

  bool _isScreenReaderEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isLargeTextEnabled = false;
  double _textScaleFactor = 1.0;

  /// Initialize accessibility service
  Future<void> initialize() async {
    try {
      // Check current accessibility settings
      await _checkAccessibilitySettings();
      
      _logger.i('Accessibility service initialized');
    } catch (e) {
      _logger.e('Failed to initialize accessibility service: $e');
    }
  }

  /// Check current accessibility settings
  Future<void> _checkAccessibilitySettings() async {
    try {
      // In a real implementation, you would use platform channels
      // to check system accessibility settings
      _logger.i('Checked accessibility settings');
    } catch (e) {
      _logger.e('Failed to check accessibility settings: $e');
    }
  }

  /// Get accessibility information
  AccessibilityInfo getAccessibilityInfo() {
    return AccessibilityInfo(
      isScreenReaderEnabled: _isScreenReaderEnabled,
      isHighContrastEnabled: _isHighContrastEnabled,
      isLargeTextEnabled: _isLargeTextEnabled,
      textScaleFactor: _textScaleFactor,
    );
  }

  /// Announce message to screen reader
  void announceToScreenReader(String message) {
    try {
      SemanticsService.announce(message, TextDirection.ltr);
      _logger.d('Announced to screen reader: $message');
    } catch (e) {
      _logger.e('Failed to announce to screen reader: $e');
    }
  }

  /// Create semantic label for images
  String createImageSemanticLabel({
    required String baseLabel,
    String? description,
    bool isDecorative = false,
  }) {
    if (isDecorative) {
      return ''; // Decorative images should have empty semantic labels
    }

    final buffer = StringBuffer(baseLabel);
    if (description != null && description.isNotEmpty) {
      buffer.write(', $description');
    }
    
    return buffer.toString();
  }

  /// Create semantic label for buttons
  String createButtonSemanticLabel({
    required String action,
    String? target,
    bool isEnabled = true,
  }) {
    final buffer = StringBuffer();
    
    if (!isEnabled) {
      buffer.write('Disabled ');
    }
    
    buffer.write(action);
    
    if (target != null && target.isNotEmpty) {
      buffer.write(' $target');
    }
    
    buffer.write(' button');
    
    return buffer.toString();
  }

  /// Create semantic label for form fields
  String createFormFieldSemanticLabel({
    required String fieldName,
    bool isRequired = false,
    String? hint,
    String? error,
  }) {
    final buffer = StringBuffer(fieldName);
    
    if (isRequired) {
      buffer.write(', required');
    }
    
    if (hint != null && hint.isNotEmpty) {
      buffer.write(', $hint');
    }
    
    if (error != null && error.isNotEmpty) {
      buffer.write(', error: $error');
    }
    
    return buffer.toString();
  }

  /// Create semantic label for status information
  String createStatusSemanticLabel({
    required String status,
    String? context,
  }) {
    final buffer = StringBuffer();
    
    if (context != null && context.isNotEmpty) {
      buffer.write('$context ');
    }
    
    buffer.write('status: $status');
    
    return buffer.toString();
  }

  /// Get recommended focus order for a list of widgets
  List<FocusNode> createFocusOrder(List<FocusNode> nodes) {
    // Return nodes in logical reading order
    return List.from(nodes);
  }

  /// Handle keyboard navigation
  bool handleKeyboardNavigation(
    RawKeyEvent event,
    List<FocusNode> focusNodes,
  ) {
    if (event is! RawKeyDownEvent) return false;

    final currentFocus = FocusScope.of(
      focusNodes.first.context ?? 
      WidgetsBinding.instance.focusManager.primaryFocus?.context ??
      NavigationService.navigatorKey.currentContext!
    ).focusedChild;

    if (currentFocus == null) return false;

    final currentIndex = focusNodes.indexOf(currentFocus);
    if (currentIndex == -1) return false;

    int? nextIndex;

    // Handle arrow key navigation
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.tab) {
      nextIndex = (currentIndex + 1) % focusNodes.length;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
               (event.logicalKey == LogicalKeyboardKey.tab && 
                event.isShiftPressed)) {
      nextIndex = (currentIndex - 1 + focusNodes.length) % focusNodes.length;
    }

    if (nextIndex != null) {
      focusNodes[nextIndex].requestFocus();
      return true;
    }

    return false;
  }

  /// Check if high contrast mode should be used
  bool shouldUseHighContrast(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.highContrast || _isHighContrastEnabled;
  }

  /// Get appropriate text scale factor
  double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.textScaleFactor * _textScaleFactor;
  }

  /// Create accessible color scheme for high contrast
  ColorScheme createHighContrastColorScheme(ColorScheme baseScheme) {
    return baseScheme.copyWith(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      error: Colors.red.shade900,
      onError: Colors.white,
    );
  }
}



/// Accessibility information data class
class AccessibilityInfo {
  final bool isScreenReaderEnabled;
  final bool isHighContrastEnabled;
  final bool isLargeTextEnabled;
  final double textScaleFactor;

  const AccessibilityInfo({
    required this.isScreenReaderEnabled,
    required this.isHighContrastEnabled,
    required this.isLargeTextEnabled,
    required this.textScaleFactor,
  });

  @override
  String toString() {
    return 'AccessibilityInfo('
        'screenReader: $isScreenReaderEnabled, '
        'highContrast: $isHighContrastEnabled, '
        'largeText: $isLargeTextEnabled, '
        'textScale: $textScaleFactor'
        ')';
  }
}

/// Widget that provides accessibility enhancements
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? hint;
  final bool excludeSemantics;
  final VoidCallback? onTap;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.hint,
    this.excludeSemantics = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget = child;

    if (onTap != null) {
      widget = GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    if (!excludeSemantics) {
      widget = Semantics(
        label: semanticLabel,
        hint: hint,
        child: widget,
      );
    }

    return widget;
  }
}

/// Accessible button widget
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool autofocus;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: onPressed,
          autofocus: autofocus,
          child: child,
        ),
      ),
    );
  }
}

/// Accessible text field widget
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool autofocus;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    
    final semanticLabel = accessibilityService.createFormFieldSemanticLabel(
      fieldName: labelText ?? 'Text field',
      isRequired: isRequired,
      hint: hintText,
      error: errorText,
    );

    return Semantics(
      label: semanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofocus: autofocus,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          suffixText: isRequired ? '*' : null,
        ),
      ),
    );
  }
}