import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_dashboard_provider.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/quick_action_button.dart';
import '../../widgets/dashboard/recent_activity_widget.dart';
import '../../widgets/charts/simple_bar_chart.dart';
import '../../widgets/charts/simple_line_chart.dart';
import '../../widgets/charts/simple_pie_chart.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/booking.dart';
import '../../../core/utils/date_formatter.dart';
import 'admin_review_management_screen.dart';
import 'user_management_screen.dart';

/// Enhanced admin dashboard screen with statistics and charts
/// 
/// Provides comprehensive overview of booking status, revenue, and quick actions
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminDashboardProvider>().refreshDashboardData();
            },
          ),
        ],
      ),
      body: Consumer<AdminDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshDashboardData(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          return ResponsiveLayout(
            mobile: _buildMobileLayout(context, provider),
            tablet: _buildTabletLayout(context, provider),
            desktop: _buildDesktopLayout(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AdminDashboardProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(context, provider),
          const SizedBox(height: 24),
          _buildQuickActionsSection(context),
          const SizedBox(height: 24),
          _buildChartsSection(context, provider),
          const SizedBox(height: 24),
          _buildRecentActivitySection(context, provider),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AdminDashboardProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(context, provider),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildChartsSection(context, provider),
                    const SizedBox(height: 24),
                    _buildRecentActivitySection(context, provider),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildQuickActionsSection(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AdminDashboardProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(context, provider),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildChartsSection(context, provider),
                    const SizedBox(height: 32),
                    _buildRecentActivitySection(context, provider),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildQuickActionsSection(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AdminDashboardProvider provider) {
    final stats = provider.stats;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 지표',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _getStatsCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            StatCard(
              title: '총 예약',
              value: stats.totalBookings.toString(),
              subtitle: '전체 예약 수',
              icon: Icons.calendar_today,
              color: Colors.blue,
              growthRate: stats.bookingGrowth,
            ),
            StatCard(
              title: '오늘 예약',
              value: stats.todayBookings.toString(),
              subtitle: '오늘 신규 예약',
              icon: Icons.today,
              color: Colors.green,
            ),
            StatCard(
              title: '총 수익',
              value: DateFormatter.formatCurrency(stats.totalRevenue),
              subtitle: '이번 달 총 수익',
              icon: Icons.attach_money,
              color: Colors.orange,
              growthRate: stats.revenueGrowth,
            ),
            StatCard(
              title: '오늘 수익',
              value: DateFormatter.formatCurrency(stats.todayRevenue),
              subtitle: '오늘 발생 수익',
              icon: Icons.trending_up,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 작업',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                QuickActionButton(
                  label: '워크샵 등록',
                  icon: Icons.add_business,
                  color: Colors.blue,
                  onPressed: () => _showComingSoon(context),
                ),
                const SizedBox(height: 12),
                QuickActionButton(
                  label: '예약 관리',
                  icon: Icons.calendar_view_day,
                  color: Colors.green,
                  onPressed: () => _showComingSoon(context),
                ),
                const SizedBox(height: 12),
                QuickActionButton(
                  label: '후기 관리',
                  icon: Icons.rate_review,
                  color: Colors.orange,
                  onPressed: () => _navigateToReviewManagement(context),
                ),
                const SizedBox(height: 12),
                QuickActionButton(
                  label: '사용자 관리',
                  icon: Icons.people,
                  color: Colors.purple,
                  onPressed: () => _navigateToUserManagement(context),
                ),
                const SizedBox(height: 12),
                QuickActionButton(
                  label: '시간대 관리',
                  icon: Icons.schedule,
                  color: Colors.teal,
                  onPressed: () => _showComingSoon(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context, AdminDashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '통계 차트',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Revenue chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SimpleLineChart(
              title: '월별 수익 추이',
              points: provider.revenueData
                  .map((data) => ChartPoint(
                        label: _formatMonthLabel(data.month),
                        value: data.revenue,
                      ))
                  .toList(),
              lineColor: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Booking status chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SimplePieChart(
              title: '예약 상태 분포',
              data: provider.bookingStatusData
                  .map((data) => PieChartData(
                        label: _getStatusLabel(data.status),
                        value: data.count.toDouble(),
                        color: _getStatusColor(data.status),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, AdminDashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 활동',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RecentActivityWidget(
          recentBookings: provider.recentBookings,
          isLoading: provider.isLoading,
          onViewAll: () => _showComingSoon(context),
        ),
      ],
    );
  }

  int _getStatsCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 600) return 2;
    return 1;
  }

  String _formatMonthLabel(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length == 2) {
      return '${parts[1]}월';
    }
    return monthKey;
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return '대기중';
      case BookingStatus.confirmed:
        return '확정';
      case BookingStatus.completed:
        return '완료';
      case BookingStatus.cancelled:
        return '취소';
      case BookingStatus.refunded:
        return '환불';
      case BookingStatus.noShow:
        return '노쇼';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.refunded:
        return Colors.purple;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }



  void _navigateToReviewManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminReviewManagementScreen(),
      ),
    );
  }

  void _navigateToUserManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserManagementScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('곧 출시 예정입니다')),
    );
  }
}