import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/review.dart';

class ReviewWriteScreen extends StatefulWidget {
  final String? workshopId;
  final String? workshopTitle;
  final ReviewType reviewType;

  const ReviewWriteScreen({
    super.key,
    this.workshopId,
    this.workshopTitle,
    this.reviewType = ReviewType.workshop,
  });

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reviewType == ReviewType.workshop ? '워크샵 후기 작성' : '앱 피드백 작성'),
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildForm(),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.reviewType == ReviewType.workshop) ...[
            _buildWorkshopInfo(),
            const SizedBox(height: 24),
          ],
          _buildRatingSection(),
          const SizedBox(height: 24),
          _buildCommentSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildWorkshopInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '워크샵 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.workshopTitle ?? '워크샵',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '별점 평가',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = rating;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  rating <= _selectedRating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: rating <= _selectedRating 
                      ? Colors.amber 
                      : Colors.grey[400],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(_selectedRating),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        if (_selectedRating == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '별점을 선택해주세요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.reviewType == ReviewType.workshop ? '후기 내용' : '피드백 내용',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _commentController,
          label: widget.reviewType == ReviewType.workshop 
              ? '워크샵은 어떠셨나요?' 
              : '앱에 대한 의견을 알려주세요',
          maxLines: 5,
          validator: (value) => Review.validateComment(value),
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 8),
        Text(
          '${_commentController.text.length}/500',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Consumer2<ReviewProvider, AuthProvider>(
      builder: (context, reviewProvider, authProvider, child) {
        final isLoading = _isSubmitting || reviewProvider.isLoading;
        
        return SizedBox(
          width: double.infinity,
          child: AppButton(
            text: '후기 등록',
            onPressed: isLoading ? null : _submitReview,
            isLoading: isLoading,
          ),
        );
      },
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '매우 불만족';
      case 2:
        return '불만족';
      case 3:
        return '보통';
      case 4:
        return '만족';
      case 5:
        return '매우 만족';
      default:
        return '별점을 선택해주세요';
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점을 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = context.read<AuthProvider>();
    final reviewProvider = context.read<ReviewProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final success = await reviewProvider.createReview(
      userId: user.id,
      userName: user.name,
      workshopId: widget.workshopId,
      workshopTitle: widget.workshopTitle,
      type: widget.reviewType,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('후기가 등록되었습니다')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reviewProvider.error ?? '후기 등록에 실패했습니다'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}