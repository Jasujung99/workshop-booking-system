import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import '../../theme/app_theme.dart';

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<int> columns;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    required this.children,
    required this.columns,
    this.spacing = AppTheme.spacingMd,
    this.runSpacing = AppTheme.spacingMd,
    this.padding,
    super.key,
  });

  /// Create a responsive grid with common column configurations
  factory ResponsiveGrid.adaptive({
    required List<Widget> children,
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    int largeDesktopColumns = 4,
    double spacing = AppTheme.spacingMd,
    double runSpacing = AppTheme.spacingMd,
    EdgeInsetsGeometry? padding,
  }) {
    return ResponsiveGrid(
      children: children,
      columns: ResponsiveValue(
        mobile: mobileColumns,
        tablet: tabletColumns,
        desktop: desktopColumns,
        largeDesktop: largeDesktopColumns,
      ),
      spacing: spacing,
      runSpacing: runSpacing,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        final columnCount = columns.getValue(deviceType);
        
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              childAspectRatio: 1.0,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
}

/// Responsive wrap that adapts spacing based on screen size
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<double> spacing;
  final ResponsiveValue<double> runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final Axis direction;

  const ResponsiveWrap({
    required this.children,
    required this.spacing,
    required this.runSpacing,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.direction = Axis.horizontal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        return Wrap(
          spacing: spacing.getValue(deviceType),
          runSpacing: runSpacing.getValue(deviceType),
          alignment: alignment,
          crossAxisAlignment: crossAxisAlignment,
          direction: direction,
          children: children,
        );
      },
    );
  }
}

/// Responsive container with adaptive padding and constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final ResponsiveValue<EdgeInsetsGeometry>? padding;
  final ResponsiveValue<double>? maxWidth;
  final bool centerContent;

  const ResponsiveContainer({
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        Widget content = child;

        // Apply max width constraint if specified
        if (maxWidth != null) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth!.getValue(deviceType),
            ),
            child: content,
          );
        }

        // Center content if requested
        if (centerContent) {
          content = Center(child: content);
        }

        // Apply responsive padding
        if (padding != null) {
          content = Padding(
            padding: padding!.getValue(deviceType),
            child: content,
          );
        }

        return content;
      },
    );
  }
}