import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/layout/responsive_layout.dart';
import '../../widgets/notifications/notification_bell.dart';
import '../workshop/workshop_list_screen_fixed.dart';
import '../booking/booking_list_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'home_screen_fixed.dart';
import '../../../main_fixed.dart';

/// Main screen with bottom navigation for user interface
/// 
/// Provides navigation between different sections of the app
/// and adapts the interface based on user role (user vs admin)
class MainScreenFixed extends StatefulWidget {
  const MainScreenFixed({super.key});

  @override
  State<MainScreenFixed> createState() => _MainScreenFixedState();
}

class _MainScreenFixedState extends State<MainScreenFixed> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<MockAuthProvider>(
      builder: (context, authProvider, child) {
        final isAdmin = authProvider.isAdmin;
        
        return ResponsiveLayout(
          mobile: _buildMobileLayout(isAdmin),
          tablet: _buildTabletLayout(isAdmin),
          desktop: _buildDesktopLayout(isAdmin),
        );
      },
    );
  }

  /// Build mobile layout with bottom navigation
  Widget _buildMobileLayout(bool isAdmin) {
    final screens = _getScreens(isAdmin);
    final navItems = _getNavigationItems(isAdmin);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: navItems,
      ),
    );
  }

  /// Build tablet layout with side navigation
  Widget _buildTabletLayout(bool isAdmin) {
    final screens = _getScreens(isAdmin);
    final navItems = _getNavigationItems(isAdmin);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            destinations: navItems.map((item) => NavigationRailDestination(
              icon: item.icon,
              selectedIcon: item.activeIcon,
              label: Text(item.label ?? ''),
            )).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }

  /// Build desktop layout with permanent side navigation
  Widget _buildDesktopLayout(bool isAdmin) {
    final screens = _getScreens(isAdmin);
    final navItems = _getNavigationItems(isAdmin);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // App header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business_center,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Workshop Booking',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const NotificationBell(),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Navigation items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isSelected = index == _currentIndex;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: ListTile(
                          leading: isSelected ? item.activeIcon : item.icon,
                          title: Text(item.label ?? ''),
                          selected: isSelected,
                          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                          selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () => _onTabTapped(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }

  /// Get screens based on user role
  List<Widget> _getScreens(bool isAdmin) {
    if (isAdmin) {
      return [
        const AdminDashboardScreen(),
        const WorkshopListScreenFixed(),
        const BookingListScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const HomeScreenFixed(),
        const WorkshopListScreenFixed(),
        const BookingListScreen(),
        const ProfileScreen(),
      ];
    }
  }

  /// Get navigation items based on user role
  List<BottomNavigationBarItem> _getNavigationItems(bool isAdmin) {
    if (isAdmin) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: '대시보드',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.business_center_outlined),
          activeIcon: Icon(Icons.business_center),
          label: '워크샵',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: '예약',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '프로필',
        ),
      ];
    } else {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.business_center_outlined),
          activeIcon: Icon(Icons.business_center),
          label: '워크샵',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: '내 예약',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '프로필',
        ),
      ];
    }
  }

  /// Handle tab selection
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}