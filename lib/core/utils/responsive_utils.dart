import 'package:flutter/material.dart';
import '../../presentation/widgets/layout/responsive_layout.dart';
import '../../presentation/theme/app_theme.dart';

/// Utility class for responsive design helpers
class ResponsiveUtils {
  /// Get responsive padding based on device type
  static EdgeInsetsGeometry getResponsivePadding(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(AppTheme.spacingMd);
      case DeviceType.tablet:
        return const EdgeInsets.all(AppTheme.spacingLg);
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(AppTheme.spacingXl);
    }
  }

  /// Get responsive margin based on device type
  static EdgeInsetsGeometry getResponsiveMargin(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(AppTheme.spacingSm);
      case DeviceType.tablet:
        return const EdgeInsets.all(AppTheme.spacingMd);
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(AppTheme.spacingLg);
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.desktop:
        return 1.2;
      case DeviceType.largeDesktop:
        return 1.3;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, {double baseSize = 24}) {
    final multiplier = getFontSizeMultiplier(context);
    return baseSize * multiplier;
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return BorderRadius.circular(AppTheme.radiusMd);
      case DeviceType.tablet:
        return BorderRadius.circular(AppTheme.radiusLg);
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return BorderRadius.circular(AppTheme.radiusXl);
    }
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return AppTheme.elevationSm;
      case DeviceType.tablet:
        return AppTheme.elevationMd;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return AppTheme.elevationLg;
    }
  }

  /// Get responsive content width
  static double getResponsiveContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth;
      case DeviceType.tablet:
        return screenWidth * 0.9;
      case DeviceType.desktop:
        return screenWidth * 0.8;
      case DeviceType.largeDesktop:
        return screenWidth * 0.7;
    }
  }

  /// Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }

  /// Check if device supports hover interactions
  static bool supportsHover(BuildContext context) {
    return ResponsiveLayout.isDesktop(context);
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return kToolbarHeight;
      case DeviceType.tablet:
        return kToolbarHeight + 8;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return kToolbarHeight + 16;
    }
  }

  /// Get responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth * 0.9;
      case DeviceType.tablet:
        return 400;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 500;
    }
  }
}