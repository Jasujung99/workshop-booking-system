import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/workshop_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../workshop/workshop_list_screen.dart';
import '../booking/booking_list_screen.dart';
import '../../../domain/entities/booking.dart';

/// Home screen for regular users
/// 
/// Displays welcome message, quick stats, featured workshops,
/// and quick action buttons for main app features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Load initial data for home screen
  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workshopProvider = context.read<WorkshopProvider>();
      final bookingProvider = context.read<BookingProvider>();
      
      // Load featured workshops (first few)
      workshopProvider.loadWorkshops(refresh: true);
      
      // Load user's recent bookings
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        bookingProvider.loadBookings(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: AppTheme.spacingLg),
                    _buildQuickActions(),
                    const SizedBox(height: AppTheme.spacingLg),
                    _buildQuickStats(),
                    const SizedBox(height: AppTheme.spacingLg),
                    _buildFeaturedWorkshops(),
                    const SizedBox(height: AppTheme.spacingLg),
                    _buildRecentBookings(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: AppTheme.spacingXl),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildQuickActions(),
                              const SizedBox(height: AppTheme.spacingLg),
                              _buildQuickStats(),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingLg),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _buildFeaturedWorkshops(),
                              const SizedBox(height: AppTheme.spacingLg),
                              _buildRecentBookings(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: AppTheme.spacingXl),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildQuickActions(),
                              const SizedBox(height: AppTheme.spacingLg),
                              _buildQuickStats(),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingXl),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildFeaturedWorkshops(),
                              const SizedBox(height: AppTheme.spacingLg),
                              _buildRecentBookings(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build app bar
  Widget _buildAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Workshop Booking',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to workshop search
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkshopListScreen(showSearchBar: true),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Build welcome section
  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final timeOfDay = _getTimeOfDay();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$timeOfDay, ${user?.name ?? '사용자'}님!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  '오늘도 새로운 워크샵을 탐험해보세요.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '빠른 실행',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.search,
                    label: '워크샵 찾기',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WorkshopListScreen(showSearchBar: true),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.calendar_today,
                    label: '내 예약',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BookingListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick stats section
  Widget _buildQuickStats() {
    return Consumer2<WorkshopProvider, BookingProvider>(
      builder: (context, workshopProvider, bookingProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '한눈에 보기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.business_center,
                        label: '전체 워크샵',
                        value: '${workshopProvider.allWorkshops.length}',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.calendar_today,
                        label: '내 예약',
                        value: '${bookingProvider.allBookings.length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build stat item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Build featured workshops section
  Widget _buildFeaturedWorkshops() {
    return Consumer<WorkshopProvider>(
      builder: (context, workshopProvider, child) {
        if (workshopProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              child: LoadingWidget(),
            ),
          );
        }

        if (workshopProvider.errorMessage != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: AppErrorWidget(
                message: workshopProvider.errorMessage!,
                onRetry: () => workshopProvider.loadWorkshops(refresh: true),
              ),
            ),
          );
        }

        final featuredWorkshops = workshopProvider.workshops.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '추천 워크샵',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WorkshopListScreen(),
                          ),
                        );
                      },
                      child: const Text('전체 보기'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                if (featuredWorkshops.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Text(
                        '아직 등록된 워크샵이 없습니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                else
                  ...featuredWorkshops.map((workshop) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.business_center,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        workshop.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '₩${workshop.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to workshop detail
                      },
                    ),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build recent bookings section
  Widget _buildRecentBookings() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              child: LoadingWidget(),
            ),
          );
        }

        final recentBookings = bookingProvider.allBookings.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최근 예약',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BookingListScreen(),
                          ),
                        );
                      },
                      child: const Text('전체 보기'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                if (recentBookings.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Text(
                        '아직 예약 내역이 없습니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                else
                  ...recentBookings.map((booking) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getBookingStatusColor(booking.status).withValues(alpha: 0.2),
                        child: Icon(
                          _getBookingStatusIcon(booking.status),
                          color: _getBookingStatusColor(booking.status),
                        ),
                      ),
                      title: Text(
                        booking.itemId ?? '워크샵',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatBookingDate(booking.createdAt),
                      ),
                      trailing: Text(
                        _getBookingStatusText(booking.status),
                        style: TextStyle(
                          color: _getBookingStatusColor(booking.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        // TODO: Navigate to booking detail
                      },
                    ),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get time of day greeting
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침';
    } else if (hour < 18) {
      return '좋은 오후';
    } else {
      return '좋은 저녁';
    }
  }

  /// Get booking status color
  Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.noShow:
        return Colors.grey;
      case BookingStatus.refunded:
        return Colors.purple;
    }
  }

  /// Get booking status icon
  IconData _getBookingStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.noShow:
        return Icons.person_off;
      case BookingStatus.refunded:
        return Icons.money_off;
    }
  }

  /// Get booking status text
  String _getBookingStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return '확정';
      case BookingStatus.pending:
        return '대기';
      case BookingStatus.cancelled:
        return '취소';
      case BookingStatus.completed:
        return '완료';
      case BookingStatus.noShow:
        return '노쇼';
      case BookingStatus.refunded:
        return '환불';
    }
  }

  /// Format booking date
  String _formatBookingDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '$difference일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// Refresh all data
  Future<void> _refreshData() async {
    final workshopProvider = context.read<WorkshopProvider>();
    final bookingProvider = context.read<BookingProvider>();
    
    final user = context.read<AuthProvider>().currentUser;
    await Future.wait([
      workshopProvider.refreshWorkshops(),
      if (user != null) bookingProvider.loadBookings(user.id),
    ]);
  }
}