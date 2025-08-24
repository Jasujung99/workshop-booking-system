import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/workshop.dart';
import '../../../domain/entities/time_slot.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';

/// Workshop detail screen with booking functionality
/// 
/// Displays detailed workshop information and available time slots
/// for booking. Supports responsive layout for different screen sizes.
class WorkshopDetailScreen extends StatefulWidget {
  final Workshop workshop;
  
  const WorkshopDetailScreen({
    super.key,
    required this.workshop,
  });

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  bool _isLoading = false;
  List<TimeSlot> _availableTimeSlots = [];
  TimeSlot? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _loadAvailableTimeSlots();
  }

  /// Load available time slots for the workshop
  void _loadAvailableTimeSlots() {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load actual time slots from repository
    // For now, create mock data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _availableTimeSlots = _generateMockTimeSlots();
          _isLoading = false;
        });
      }
    });
  }

  /// Generate mock time slots for demonstration
  List<TimeSlot> _generateMockTimeSlots() {
    final now = DateTime.now();
    final slots = <TimeSlot>[];
    
    for (int i = 1; i <= 7; i++) {
      final date = now.add(Duration(days: i));
      
      // Morning slot
      slots.add(TimeSlot(
        id: 'slot_${i}_morning',
        date: date,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        type: SlotType.workshop,
        itemId: widget.workshop.id,
        isAvailable: i % 3 != 0, // Make some slots unavailable
        maxCapacity: widget.workshop.capacity,
        currentBookings: i % 4, // Mock current bookings
        createdAt: now,
      ));
      
      // Afternoon slot
      slots.add(TimeSlot(
        id: 'slot_${i}_afternoon',
        date: date,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
        type: SlotType.workshop,
        itemId: widget.workshop.id,
        isAvailable: i % 2 != 0, // Make some slots unavailable
        maxCapacity: widget.workshop.capacity,
        currentBookings: i % 3, // Mock current bookings
        createdAt: now,
      ));
    }
    
    return slots;
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWorkshopInfo(),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildTimeSlotSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildWorkshopInfo(),
                  ),
                  const SizedBox(width: AppTheme.spacingLg),
                  Expanded(
                    flex: 1,
                    child: _buildTimeSlotSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildWorkshopInfo(),
                  ),
                  const SizedBox(width: AppTheme.spacingXl),
                  Expanded(
                    flex: 2,
                    child: _buildTimeSlotSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  /// Build sliver app bar with workshop image
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.workshop.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: widget.workshop.imageUrl != null
            ? Image.network(
                widget.workshop.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  /// Build image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.business_center,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Build workshop information section
  Widget _buildWorkshopInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Workshop title (for mobile when not in app bar)
        Text(
          widget.workshop.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        
        // Workshop details
        Row(
          children: [
            _buildInfoChip(
              icon: Icons.attach_money,
              label: widget.workshop.formattedPrice,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            _buildInfoChip(
              icon: Icons.people,
              label: '최대 ${widget.workshop.capacity}명',
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),
        
        // Workshop description
        Text(
          '설명',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          widget.workshop.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
        
        // Workshop tags
        if (widget.workshop.tags.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            '태그',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: widget.workshop.tags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            )).toList(),
          ),
        ],
        
        // Workshop metadata
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          '정보',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildMetadataItem(
          icon: Icons.calendar_today,
          label: '등록일',
          value: _formatDate(widget.workshop.createdAt),
        ),
        if (widget.workshop.updatedAt != null)
          _buildMetadataItem(
            icon: Icons.update,
            label: '수정일',
            value: _formatDate(widget.workshop.updatedAt!),
          ),
      ],
    );
  }

  /// Build info chip
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build metadata item
  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build time slot section
  Widget _buildTimeSlotSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '예약 가능한 시간',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingLg),
                  child: LoadingWidget(),
                ),
              )
            else if (_availableTimeSlots.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        '예약 가능한 시간이 없습니다',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: _availableTimeSlots.map((timeSlot) {
                  return _buildTimeSlotCard(timeSlot);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build time slot card
  Widget _buildTimeSlotCard(TimeSlot timeSlot) {
    final isSelected = _selectedTimeSlot?.id == timeSlot.id;
    final availableSpots = timeSlot.maxCapacity - timeSlot.currentBookings;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        onTap: timeSlot.isAvailable ? () {
          setState(() {
            _selectedTimeSlot = isSelected ? null : timeSlot;
          });
        } : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(timeSlot.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    '${_formatTime(timeSlot.startTime)} - ${_formatTime(timeSlot.endTime)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        '${timeSlot.currentBookings}/${timeSlot.maxCapacity}명',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  if (!timeSlot.isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '마감',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (availableSpots <= 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${availableSpots}자리 남음',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build booking button
  Widget _buildBookingButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to login
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('예약하려면 로그인이 필요합니다'),
                    ),
                  );
                },
                child: const Text('로그인 후 예약하기'),
              ),
            ),
          );
        }

        final canBook = _selectedTimeSlot != null && _selectedTimeSlot!.isAvailable;
        
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canBook ? _handleBooking : null,
              child: Text(
                _selectedTimeSlot == null 
                    ? '시간대를 선택해주세요'
                    : '${widget.workshop.formattedPrice} 예약하기',
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle booking action
  void _handleBooking() {
    if (_selectedTimeSlot == null) return;
    
    // TODO: Navigate to booking confirmation screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_formatDate(_selectedTimeSlot!.date)} ${_formatTime(_selectedTimeSlot!.startTime)} 예약이 선택되었습니다',
        ),
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  /// Format time
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}