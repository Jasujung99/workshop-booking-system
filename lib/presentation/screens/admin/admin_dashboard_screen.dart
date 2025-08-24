import 'package:flutter/material.dart';
import 'admin_review_management_screen.dart';

/// Admin dashboard screen
/// 
/// Provides navigation to various admin functions
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '관리 메뉴',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          context,
          title: '워크샵 관리',
          subtitle: '워크샵 등록 및 수정',
          icon: Icons.business_center,
          color: Colors.blue,
          onTap: () => _showComingSoon(context),
        ),
        _buildDashboardCard(
          context,
          title: '예약 관리',
          subtitle: '예약 현황 및 관리',
          icon: Icons.calendar_today,
          color: Colors.green,
          onTap: () => _showComingSoon(context),
        ),
        _buildDashboardCard(
          context,
          title: '후기 관리',
          subtitle: '후기 및 피드백 관리',
          icon: Icons.rate_review,
          color: Colors.orange,
          onTap: () => _navigateToReviewManagement(context),
        ),
        _buildDashboardCard(
          context,
          title: '사용자 관리',
          subtitle: '사용자 정보 관리',
          icon: Icons.people,
          color: Colors.purple,
          onTap: () => _showComingSoon(context),
        ),
        _buildDashboardCard(
          context,
          title: '통계',
          subtitle: '수익 및 이용 통계',
          icon: Icons.analytics,
          color: Colors.teal,
          onTap: () => _showComingSoon(context),
        ),
        _buildDashboardCard(
          context,
          title: '설정',
          subtitle: '시스템 설정',
          icon: Icons.settings,
          color: Colors.grey,
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToReviewManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminReviewManagementScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('곧 출시 예정입니다')),
    );
  }
}