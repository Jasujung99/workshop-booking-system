import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/repositories/review_repository.dart';
import '../../screens/review/review_list_screen.dart';

class ReviewSummaryWidget extends StatefulWidget {
  final String workshopId;
  final String workshopTitle;

  const ReviewSummaryWidget({
    super.key,
    required this.workshopId,
    required this.workshopTitle,
  });

  @override
  State<ReviewSummaryWidget> createState() => _ReviewSummaryWidgetState();
}

class _ReviewSummaryWidgetState extends State<ReviewSummaryWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final reviewProvider = context.read<ReviewProvider>();
    await Future.wait([
      reviewProvider.loadWorkshopReviews(widget.workshopId),
      reviewProvider.loadWorkshopStats(widget.workshopId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        final reviews = provider.workshopReviews;
        final stats = provider.currentWorkshopStats;

        if (provider.isLoading && reviews.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '후기',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (reviews.isNotEmpty)
                      TextButton(
                        onPressed: () => _navigateToReviewList(),
                        child: const Text('전체보기'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (stats != null && stats.totalReviews > 0) ...[
                  _buildRatingSummary(stats),
                  const SizedBox(height: 16),
                ],
                if (reviews.isEmpty)
                  _buildEmptyState()
                else ...[
                  ...reviews.take(3).map((review) => _buildReviewItem(review)),
                  if (reviews.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: TextButton(
                          onPressed: () => _navigateToReviewList(),
                          child: Text('${reviews.length - 3}개 후기 더보기'),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingSummary(ReviewStats stats) {
    return Row(
      children: [
        Text(
          stats.averageRating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.amber[700],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) => Icon(
                index < stats.averageRating.round() ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.amber,
              )),
            ),
            Text(
              '${stats.totalReviews}개 후기',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0] : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(5, (index) => Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            size: 12,
                            color: Colors.amber,
                          )),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              '아직 후기가 없습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '첫 번째 후기를 작성해보세요!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReviewList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewListScreen(
          workshopId: widget.workshopId,
          workshopTitle: widget.workshopTitle,
          reviewType: ReviewType.workshop,
        ),
      ),
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