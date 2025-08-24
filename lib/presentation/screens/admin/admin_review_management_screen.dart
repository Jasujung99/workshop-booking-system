import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/review.dart';

class AdminReviewManagementScreen extends StatefulWidget {
  const AdminReviewManagementScreen({super.key});

  @override
  State<AdminReviewManagementScreen> createState() => _AdminReviewManagementScreenState();
}

class _AdminReviewManagementScreenState extends State<AdminReviewManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final reviewProvider = context.read<ReviewProvider>();
    
    await Future.wait([
      reviewProvider.loadReviews(filter: ReviewFilter.forWorkshop('')),
      reviewProvider.loadAppFeedback(),
    ]);
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check admin access
    final authProvider = context.watch<AuthProvider>();
    if (!authProvider.isAuthenticated || !authProvider.currentUser!.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('접근 권한 없음')),
        body: const Center(
          child: Text('관리자만 접근할 수 있습니다'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('후기 관리'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '워크샵 후기'),
            Tab(text: '앱 피드백'),
          ],
        ),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildWorkshopReviewsTab(),
        _buildAppFeedbackTab(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildMobileLayout(),
    );
  }

  Widget _buildWorkshopReviewsTab() {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        if (!_isInitialized && provider.isLoading) {
          return const LoadingWidget();
        }

        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: _loadData,
          );
        }

        final workshopReviews = provider.reviews
            .where((review) => review.type == ReviewType.workshop)
            .toList();

        if (workshopReviews.isEmpty) {
          return _buildEmptyState('워크샵 후기가 없습니다');
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workshopReviews.length,
            itemBuilder: (context, index) {
              return _buildAdminReviewCard(workshopReviews[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildAppFeedbackTab() {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        if (!_isInitialized && provider.isLoading) {
          return const LoadingWidget();
        }

        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: _loadData,
          );
        }

        final appFeedback = provider.appFeedback;

        if (appFeedback.isEmpty) {
          return _buildEmptyState('앱 피드백이 없습니다');
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appFeedback.length,
            itemBuilder: (context, index) {
              return _buildAdminReviewCard(appFeedback[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildAdminReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and actions
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0] : 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: review.type == ReviewType.workshop 
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              review.type == ReviewType.workshop ? '워크샵' : '앱',
                              style: TextStyle(
                                color: review.type == ReviewType.workshop 
                                    ? Colors.blue 
                                    : Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) => Icon(
                              index < review.rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            )),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, review),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'respond',
                      child: Row(
                        children: [
                          Icon(Icons.reply),
                          SizedBox(width: 8),
                          Text('응답하기'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Workshop info (if applicable)
            if (review.workshopTitle != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review.workshopTitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Review content
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 12),
            
            // Admin actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showUserDetails(review),
                  icon: const Icon(Icons.person, size: 16),
                  label: const Text('사용자 정보'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _respondToReview(review),
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('응답하기'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Review review) {
    switch (action) {
      case 'respond':
        _respondToReview(review);
        break;
      case 'delete':
        _showDeleteDialog(review);
        break;
    }
  }

  void _respondToReview(Review review) {
    showDialog(
      context: context,
      builder: (context) => _ResponseDialog(review: review),
    );
  }

  void _showUserDetails(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이름: ${review.userName}'),
            const SizedBox(height: 8),
            Text('사용자 ID: ${review.userId}'),
            const SizedBox(height: 8),
            Text('작성일: ${_formatDate(review.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('후기 삭제'),
        content: const Text('이 후기를 삭제하시겠습니까?\n삭제된 후기는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteReview(review);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(Review review) async {
    // TODO: Implement delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('삭제 기능은 추후 구현 예정입니다')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ResponseDialog extends StatefulWidget {
  final Review review;

  const _ResponseDialog({required this.review});

  @override
  State<_ResponseDialog> createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<_ResponseDialog> {
  final _responseController = TextEditingController();

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('후기에 응답하기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original review
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < widget.review.rating ? Icons.star : Icons.star_border,
                        size: 14,
                        color: Colors.amber,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.review.comment),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Response input
          TextField(
            controller: _responseController,
            decoration: const InputDecoration(
              labelText: '응답 내용',
              hintText: '고객에게 보낼 응답을 작성해주세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _sendResponse,
          child: const Text('응답 보내기'),
        ),
      ],
    );
  }

  void _sendResponse() {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('응답 내용을 입력해주세요')),
      );
      return;
    }

    // TODO: Implement response functionality
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('응답 기능은 추후 구현 예정입니다')),
    );
  }
}