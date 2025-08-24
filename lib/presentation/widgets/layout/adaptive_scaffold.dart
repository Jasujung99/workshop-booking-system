import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import '../../theme/app_theme.dart';

/// Adaptive scaffold that changes layout based on screen size
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final List<Widget>? persistentFooterButtons;
  final Widget? navigationRail;
  final bool showNavigationRail;

  const AdaptiveScaffold({
    required this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.persistentFooterButtons,
    this.navigationRail,
    this.showNavigationRail = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        // For desktop, show navigation rail instead of bottom navigation
        if (deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop) {
          return _buildDesktopLayout(context);
        }
        
        // For mobile and tablet, use standard scaffold
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomSheet: bottomSheet,
      persistentFooterButtons: persistentFooterButtons,
      body: Row(
        children: [
          if (navigationRail != null && showNavigationRail) ...[
            navigationRail!,
            const VerticalDivider(width: 1),
          ],
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      persistentFooterButtons: persistentFooterButtons,
    );
  }
}

/// Adaptive navigation rail for desktop layouts
class AdaptiveNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final Widget? leading;
  final Widget? trailing;
  final bool extended;
  final double? minWidth;
  final double? minExtendedWidth;

  const AdaptiveNavigationRail({
    required this.selectedIndex,
    required this.destinations,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.extended = false,
    this.minWidth,
    this.minExtendedWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      leading: leading,
      trailing: trailing,
      extended: extended,
      minWidth: minWidth ?? 72,
      minExtendedWidth: minExtendedWidth ?? 256,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: AppTheme.elevationSm,
    );
  }
}

/// Responsive sidebar that can be a drawer on mobile or permanent on desktop
class ResponsiveSidebar extends StatelessWidget {
  final Widget child;
  final double width;
  final bool isOpen;
  final VoidCallback? onClose;

  const ResponsiveSidebar({
    required this.child,
    this.width = 280,
    this.isOpen = false,
    this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        // On desktop, show as permanent sidebar
        if (deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop) {
          return Container(
            width: width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: child,
          );
        }
        
        // On mobile/tablet, show as drawer
        return Drawer(
          width: width,
          child: child,
        );
      },
    );
  }
}