import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

/// Device type based on screen width
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive layout widget that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = _getDeviceType(constraints.maxWidth);
        
        switch (deviceType) {
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }

  static DeviceType _getDeviceType(double width) {
    if (width >= Breakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Get device type from context
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return _getDeviceType(width);
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  }
}

/// Responsive builder that provides device type and constraints
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    DeviceType deviceType,
    BoxConstraints constraints,
  ) builder;

  const ResponsiveBuilder({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveLayout._getDeviceType(constraints.maxWidth);
        return builder(context, deviceType, constraints);
      },
    );
  }
}

/// Responsive value that changes based on device type
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  T getValue(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  T getValueFromContext(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    return getValue(deviceType);
  }
}