import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      color: color,
      elevation: elevation ?? AppTheme.elevationSm,
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        side: border ?? BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        child: card,
      );
    }

    return card;
  }
}

class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const AppListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding ?? 
          const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
    );
  }
}