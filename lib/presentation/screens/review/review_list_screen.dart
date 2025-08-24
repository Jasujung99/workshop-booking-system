import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/repositories/review_repository.dart';
import 'review_write_screen.dart';

class ReviewListScreen extends StatefulWidget {
  final String? workshopId;
  final String? workshopTitle;
  final ReviewType reviewType;

  const ReviewListScreen({
    super.key,
    this.workshopId,
    this.workshopTitle,
    this.reviewType = ReviewType.workshop,
  });

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.reviewType == ReviewType.workshop ? 2 : 1,
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final reviewProvider = context.read<ReviewProvider>();
    
    if (widget.reviewType == ReviewType.workshop && widget.workshopId != null) {
      await Future.wait([
        reviewProvider.loadWorkshopReviews(widget.workshopId!),
        reviewProvider.loadWorkshopStats(widget.workshopId!),
      ]);
    } else {
      await reviewProvider.loadAppFeedback();
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reviewType == ReviewType.workshop 
            ? '워크샵 후기' 
            : '앱 피드백'),
        elevation: 0,
        bottom: widget.reviewType == ReviewType.workshop 
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '후기 목록'),
                  Tab(text: '통계'),
                ],
              )
            : null,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMobileLayout() {
    if (widget.reviewType == ReviewType.workshop) {
      return TabBarView(
        controller: _tabController,
        children: [
          _buildReviewList(),
          _buildStatistics(),
        ],
      );
    } else {
      return _buildReviewList();
    }
  }

  Widget _buildTabletLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildMobileLayout(),
    );
  }

  Widget _buildReviewList() {
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

        final reviews = widget.reviewType == ReviewType.workshop
            ? provider.workshopReviews
            : provider.appFeedback;

        if (reviews.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(reviews[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        final stats = provider.currentWorkshopStats;
        
        if (stats == null) {
          return const Center(child: Text('통계 정보를 불러올 수 없습니다'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallStats(stats),
              const SizedBox(height: 24),
              _buildRatingDistribution(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallStats(ReviewStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 통계',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '평균 별점',
                    '${stats.averageRating.toStringAsFixed(1)}점',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '총 후기 수',
                    '${stats.totalReviews}개',
                    Icons.reviews,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(ReviewStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '별점 분포',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              final rating = 5 - index;
              final count = stats.ratingDistribution[rating] ?? 0;
              final percentage = stats.getRatingPercentage(rating);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(rating, (i) => const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.amber.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$count개 (${percentage.toStringAsFixed(1)}%)',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text(
                        review.userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                if (context.read<AuthProvider>().currentUser?.isAdmin == true)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(review);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('삭제'),
                      ),
                    ],
                  ),
              ],
            ),
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
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.reviewType == ReviewType.workshop 
                ? Icons.rate_review_outlined 
                : Icons.feedback_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.reviewType == ReviewType.workshop 
                ? '아직 후기가 없습니다' 
                : '아직 피드백이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.reviewType == ReviewType.workshop 
                ? '첫 번째 후기를 작성해보세요!' 
                : '첫 번째 피드백을 남겨보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.currentUser == null) return null;

    return FloatingActionButton.extended(
      onPressed: () => _navigateToWriteReview(),
      icon: const Icon(Icons.edit),
      label: Text(widget.reviewType == ReviewType.workshop ? '후기 작성' : '피드백 작성'),
    );
  }

  void _navigateToWriteReview() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ReviewWriteScreen(
          workshopId: widget.workshopId,
          workshopTitle: widget.workshopTitle,
          reviewType: widget.reviewType,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _showDeleteDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('후기 삭제'),
        content: const Text('이 후기를 삭제하시겠습니까?'),
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}