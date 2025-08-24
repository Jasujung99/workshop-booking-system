import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../domain/entities/workshop.dart';
import '../../../domain/entities/time_slot.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import 'booking_confirmation_screen.dart';

/// Time slot selection screen for workshop booking
/// 
/// Displays a calendar widget and available time slots for the selected date.
/// Handles time slot selection and navigation to booking confirmation.
class TimeSlotSelectionScreen extends StatefulWidget {
  final Workshop workshop;
  
  const TimeSlotSelectionScreen({
    super.key,
    required this.workshop,
  });

  @override
  State<TimeSlotSelectionScreen> createState() => _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBookingProcess();
      _loadTimeSlotsForDate(_selectedDate);
    });
  }

  /// Initialize booking process
  void _initializeBookingProcess() {
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.startBookingProcess(widget.workshop.id);
  }

  /// Load time slots for selected date
  void _loadTimeSlotsForDate(DateTime date) {
    final bookingProvider = context.read<BookingProvider>();
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));
    
    bookingProvider.loadAvailableTimeSlots(startDate, endDate);
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
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildCalendarSection(),
            ),
            const SizedBox(width: AppTheme.spacingLg),
            Expanded(
              flex: 1,
              child: _buildTimeSlotsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildCalendarSection(),
            ),
            const SizedBox(width: AppTheme.spacingXl),
            Expanded(
              flex: 3,
              child: _buildTimeSlotsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('시간대 선택'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showBookingInfo,
          tooltip: '예약 안내',
        ),
      ],
    );
  }

  /// Build main body content
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkshopHeader(),
          const SizedBox(height: AppTheme.spacingLg),
          _buildCalendarSection(),
          const SizedBox(height: AppTheme.spacingLg),
          _buildTimeSlotsSection(),
        ],
      ),
    );
  }

  /// Build workshop header
  Widget _buildWorkshopHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // Workshop image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: widget.workshop.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.workshop.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business_center,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.business_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            
            // Workshop info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workshop.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        widget.workshop.formattedPrice,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      Text(
                        '최대 ${widget.workshop.capacity}명',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build calendar section
  Widget _buildCalendarSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '날짜 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildCalendar(),
          ],
        ),
      ),
    );
  }

  /// Build calendar widget
  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, now.day);
    final lastDay = firstDay.add(const Duration(days: 180)); // 6 months ahead
    
    return TableCalendar<TimeSlot>(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: _focusedDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      
      // Calendar style
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        disabledTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
      
      // Header style
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ?? const TextStyle(),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Theme.of(context).colorScheme.primary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      
      // Day builder
      calendarBuilders: CalendarBuilders(
        disabledBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
      
      // Event callbacks
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDate, selectedDay)) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDate = focusedDay;
            _selectedTimeSlot = null; // Clear selected time slot when date changes
          });
          _loadTimeSlotsForDate(selectedDay);
        }
      },
      
      onPageChanged: (focusedDay) {
        _focusedDate = focusedDay;
      },
      
      // Disable past dates
      enabledDayPredicate: (day) {
        return !day.isBefore(DateTime(now.year, now.month, now.day));
      },
    );
  }

  /// Build time slots section
  Widget _buildTimeSlotsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '시간대 선택',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatSelectedDate(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildTimeSlotsList(),
          ],
        ),
      ),
    );
  }

  /// Build time slots list
  Widget _buildTimeSlotsList() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              child: LoadingWidget(),
            ),
          );
        }

        if (bookingProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: AppErrorWidget(
                message: bookingProvider.errorMessage!,
                onRetry: () => _loadTimeSlotsForDate(_selectedDate),
              ),
            ),
          );
        }

        final timeSlots = bookingProvider.availableTimeSlots
            .where((slot) => isSameDay(slot.date, _selectedDate))
            .toList();

        if (timeSlots.isEmpty) {
          return Center(
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
                    '선택한 날짜에 예약 가능한 시간이 없습니다',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    '다른 날짜를 선택해보세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: timeSlots.map((timeSlot) {
            return _buildTimeSlotCard(timeSlot);
          }).toList(),
        );
      },
    );
  }

  /// Build time slot card
  Widget _buildTimeSlotCard(TimeSlot timeSlot) {
    final isSelected = _selectedTimeSlot?.id == timeSlot.id;
    final isAvailable = timeSlot.isAvailable && timeSlot.hasAvailableCapacity;
    final availableSpots = timeSlot.remainingCapacity;
    final isPast = timeSlot.isPast;
    final isBookingAllowed = timeSlot.isBookingAllowed;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        onTap: isAvailable && isBookingAllowed ? () {
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
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        timeSlot.timeRangeString,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ],
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
                  _buildTimeSlotStatus(timeSlot, isPast, isAvailable, isBookingAllowed, availableSpots),
                ],
              ),
              
              if (timeSlot.price != null && timeSlot.price != widget.workshop.price) ...[
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      '${timeSlot.price!.toInt().toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )}원',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      '(특별 가격)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build time slot status indicator
  Widget _buildTimeSlotStatus(TimeSlot timeSlot, bool isPast, bool isAvailable, bool isBookingAllowed, int availableSpots) {
    if (isPast) {
      return _buildStatusChip('지난 시간', Colors.grey);
    }
    
    if (!isAvailable) {
      return _buildStatusChip('마감', Colors.red);
    }
    
    if (!isBookingAllowed) {
      return _buildStatusChip('예약 마감', Colors.orange);
    }
    
    if (availableSpots <= 2) {
      return _buildStatusChip('${availableSpots}자리 남음', Colors.orange);
    }
    
    return _buildStatusChip('예약 가능', Colors.green);
  }

  /// Build status chip
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build bottom bar with continue button
  Widget _buildBottomBar() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final canContinue = _selectedTimeSlot != null && 
                           _selectedTimeSlot!.isAvailable && 
                           _selectedTimeSlot!.isBookingAllowed;
        
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (_selectedTimeSlot != null) ...[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택된 시간',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '${_formatSelectedDate()} ${_selectedTimeSlot!.timeRangeString}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                ],
                AppButton(
                  text: canContinue ? '다음 단계' : '시간대를 선택해주세요',
                  onPressed: canContinue ? _proceedToConfirmation : null,
                  isLoading: bookingProvider.isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Proceed to booking confirmation
  void _proceedToConfirmation() {
    if (_selectedTimeSlot == null) return;
    
    final bookingProvider = context.read<BookingProvider>();
    final price = _selectedTimeSlot!.price ?? widget.workshop.price;
    
    bookingProvider.selectTimeSlot(_selectedTimeSlot!, price);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          workshop: widget.workshop,
          timeSlot: _selectedTimeSlot!,
        ),
      ),
    );
  }

  /// Format selected date
  String _formatSelectedDate() {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[_selectedDate.weekday - 1];
    return '${_selectedDate.month}월 ${_selectedDate.day}일 ($weekday)';
  }

  /// Show booking information dialog
  void _showBookingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 안내'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 예약은 시작 1시간 전까지 가능합니다'),
            SizedBox(height: AppTheme.spacingSm),
            Text('• 취소는 시작 24시간 전까지 가능합니다'),
            SizedBox(height: AppTheme.spacingSm),
            Text('• 정원이 마감된 시간대는 선택할 수 없습니다'),
            SizedBox(height: AppTheme.spacingSm),
            Text('• 특별 가격이 적용된 시간대가 있을 수 있습니다'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}