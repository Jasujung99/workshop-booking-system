import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/time_slot_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as common_error;
import '../../widgets/layout/responsive_layout.dart';
import '../../widgets/admin/bulk_time_slot_dialog.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../core/utils/date_formatter.dart';
import 'time_slot_form_screen.dart';

/// Time slot management screen for admin
/// 
/// Allows admin to view, create, edit, and delete time slots with bulk operations
class TimeSlotManagementScreen extends StatefulWidget {
  const TimeSlotManagementScreen({super.key});

  @override
  State<TimeSlotManagementScreen> createState() => _TimeSlotManagementScreenState();
}

class _TimeSlotManagementScreenState extends State<TimeSlotManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<TimeSlotProvider>();
    await provider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시간대 관리'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showBulkCreateDialog,
            icon: const Icon(Icons.add_box),
            tooltip: '일괄 생성',
          ),
          IconButton(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            tooltip: '개별 생성',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildTimeSlotList()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildFilters(),
                const Divider(),
                _buildStats(),
              ],
            ),
          ),
        ),
        Expanded(child: _buildTimeSlotList()),
      ],
    );
  }

  Widget _buildFilters() {
    return Consumer<TimeSlotProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '필터',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildDateRangeFilter(provider),
                const SizedBox(height: 16),
                _buildWorkshopFilter(provider),
                const SizedBox(height: 16),
                _buildSlotTypeFilter(provider),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.clearFilters();
                          provider.loadTimeSlots();
                        },
                        child: const Text('필터 초기화'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.loadTimeSlots,
                        child: const Text('적용'),
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

  Widget _buildDateRangeFilter(TimeSlotProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜 범위',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectStartDate(provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatDate(provider.startDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('~'),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _selectEndDate(provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatDate(provider.endDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkshopFilter(TimeSlotProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '워크샵',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: provider.selectedWorkshopId,
          decoration: const InputDecoration(
            hintText: '모든 워크샵',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('모든 워크샵'),
            ),
            ...provider.workshops.map((workshop) {
              return DropdownMenuItem<String>(
                value: workshop.id,
                child: Text(
                  workshop.title,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: provider.updateWorkshopFilter,
        ),
      ],
    );
  }

  Widget _buildSlotTypeFilter(TimeSlotProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '타입',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SlotType>(
          value: provider.selectedSlotType,
          decoration: const InputDecoration(
            hintText: '모든 타입',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem<SlotType>(
              value: null,
              child: Text('모든 타입'),
            ),
            DropdownMenuItem<SlotType>(
              value: SlotType.workshop,
              child: Text('워크샵'),
            ),
            DropdownMenuItem<SlotType>(
              value: SlotType.space,
              child: Text('공간 대관'),
            ),
          ],
          onChanged: provider.updateSlotTypeFilter,
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Consumer<TimeSlotProvider>(
      builder: (context, provider, child) {
        final totalSlots = provider.filteredTimeSlots.length;
        final availableSlots = provider.filteredTimeSlots
            .where((slot) => slot.isAvailable && slot.hasAvailableCapacity)
            .length;
        final bookedSlots = provider.filteredTimeSlots
            .where((slot) => slot.currentBookings > 0)
            .length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '통계',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildStatItem('전체 시간대', totalSlots.toString()),
              _buildStatItem('예약 가능', availableSlots.toString()),
              _buildStatItem('예약 있음', bookedSlots.toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotList() {
    return Consumer<TimeSlotProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: LoadingWidget());
        }

        if (provider.error != null) {
          return Center(
            child: common_error.ErrorWidget(
              message: provider.error!,
              onRetry: provider.loadTimeSlots,
            ),
          );
        }

        final groupedSlots = provider.groupedTimeSlots;
        
        if (groupedSlots.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groupedSlots.length,
            itemBuilder: (context, index) {
              final date = groupedSlots.keys.elementAt(index);
              final slots = groupedSlots[date]!;
              
              return _buildDateGroup(date, slots);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '시간대가 없습니다',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 시간대를 생성해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showBulkCreateDialog,
                icon: const Icon(Icons.add_box),
                label: const Text('일괄 생성'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('개별 생성'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(DateTime date, List<TimeSlot> slots) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatDateWithWeekday(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Text(
                  '${slots.length}개',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ...slots.map((slot) => _buildTimeSlotTile(slot)),
        ],
      ),
    );
  }

  Widget _buildTimeSlotTile(TimeSlot slot) {
    final workshop = context.read<TimeSlotProvider>().workshops
        .where((w) => w.id == slot.itemId)
        .firstOrNull;

    return ListTile(
      leading: _buildSlotStatusIcon(slot),
      title: Row(
        children: [
          Text(slot.timeRangeString),
          const SizedBox(width: 8),
          _buildSlotTypeChip(slot.type),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workshop != null)
            Text('워크샵: ${workshop.title}')
          else if (slot.type == SlotType.space)
            const Text('공간 대관'),
          Text(
            '예약: ${slot.currentBookings}/${slot.maxCapacity}명',
            style: TextStyle(
              color: slot.hasAvailableCapacity
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          if (slot.price != null)
            Text('가격: ${slot.price!.toStringAsFixed(0)}원'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(value, slot),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('수정'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('삭제'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: slot.isAvailable ? 'disable' : 'enable',
            child: ListTile(
              leading: Icon(slot.isAvailable ? Icons.visibility_off : Icons.visibility),
              title: Text(slot.isAvailable ? '비활성화' : '활성화'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      onTap: () => _editTimeSlot(slot),
    );
  }

  Widget _buildSlotStatusIcon(TimeSlot slot) {
    if (!slot.isAvailable) {
      return Icon(
        Icons.visibility_off,
        color: Theme.of(context).colorScheme.outline,
      );
    }

    if (slot.currentBookings >= slot.maxCapacity) {
      return Icon(
        Icons.event_busy,
        color: Theme.of(context).colorScheme.error,
      );
    }

    if (slot.currentBookings > 0) {
      return Icon(
        Icons.event_available,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return Icon(
      Icons.event,
      color: Theme.of(context).colorScheme.outline,
    );
  }

  Widget _buildSlotTypeChip(SlotType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: type == SlotType.workshop
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type == SlotType.workshop ? '워크샵' : '공간',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: type == SlotType.workshop
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Future<void> _selectStartDate(TimeSlotProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      provider.updateDateRange(picked, provider.endDate);
    }
  }

  Future<void> _selectEndDate(TimeSlotProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.endDate,
      firstDate: provider.startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      provider.updateDateRange(provider.startDate, picked);
    }
  }

  Future<void> _showBulkCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const BulkTimeSlotDialog(),
    );

    if (result == true) {
      await context.read<TimeSlotProvider>().loadTimeSlots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시간대가 일괄 생성되었습니다')),
        );
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const TimeSlotFormScreen(),
      ),
    );

    if (result == true) {
      await context.read<TimeSlotProvider>().loadTimeSlots();
    }
  }

  Future<void> _editTimeSlot(TimeSlot slot) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TimeSlotFormScreen(
          timeSlot: slot,
          isEditing: true,
        ),
      ),
    );

    if (result == true) {
      await context.read<TimeSlotProvider>().loadTimeSlots();
    }
  }

  Future<void> _handleMenuAction(String action, TimeSlot slot) async {
    switch (action) {
      case 'edit':
        await _editTimeSlot(slot);
        break;
      case 'delete':
        await _deleteTimeSlot(slot);
        break;
      case 'enable':
      case 'disable':
        await _toggleSlotAvailability(slot);
        break;
    }
  }

  Future<void> _deleteTimeSlot(TimeSlot slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시간대 삭제'),
        content: Text(
          '${DateFormatter.formatDate(slot.date)} ${slot.timeRangeString} 시간대를 삭제하시겠습니까?\n\n'
          '현재 ${slot.currentBookings}개의 예약이 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<TimeSlotProvider>();
      final success = await provider.deleteTimeSlot(slot.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '시간대가 삭제되었습니다' : '삭제에 실패했습니다'),
          ),
        );
      }
    }
  }

  Future<void> _toggleSlotAvailability(TimeSlot slot) async {
    final provider = context.read<TimeSlotProvider>();
    final updatedSlot = slot.copyWith(isAvailable: !slot.isAvailable);
    
    final success = await provider.updateTimeSlot(updatedSlot);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? '시간대가 ${updatedSlot.isAvailable ? '활성화' : '비활성화'}되었습니다'
                : '상태 변경에 실패했습니다',
          ),
        ),
      );
    }
  }