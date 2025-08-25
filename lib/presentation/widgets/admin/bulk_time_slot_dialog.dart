import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/time_slot_provider.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';
import '../common/loading_widget.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../core/utils/date_formatter.dart';

class BulkTimeSlotDialog extends StatefulWidget {
  const BulkTimeSlotDialog({super.key});

  @override
  State<BulkTimeSlotDialog> createState() => _BulkTimeSlotDialogState();
}

class _BulkTimeSlotDialogState extends State<BulkTimeSlotDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Form state
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  int _slotDurationMinutes = 60;
  SlotType _slotType = SlotType.workshop;
  String? _selectedWorkshopId;
  int _maxCapacity = 10;
  double? _price;
  final Set<int> _excludeWeekdays = {};

  // Controllers
  final _capacityController = TextEditingController(text: '10');
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '60');

  @override
  void dispose() {
    _capacityController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: _buildForm(),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            Icons.schedule,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            '시간대 일괄 생성',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Consumer<TimeSlotProvider>(
      builder: (context, provider, child) {
        if (provider.isBulkCreating) {
          return _buildProgressIndicator(provider);
        }

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDateRangeSection(),
              const SizedBox(height: 16),
              _buildTimeSection(),
              const SizedBox(height: 16),
              _buildDurationSection(),
              const SizedBox(height: 16),
              _buildTypeSection(),
              const SizedBox(height: 16),
              _buildWorkshopSection(),
              const SizedBox(height: 16),
              _buildCapacitySection(),
              const SizedBox(height: 16),
              _buildPriceSection(),
              const SizedBox(height: 16),
              _buildWeekdaySection(),
              if (provider.error != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(provider.error!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(TimeSlotProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingWidget(),
          const SizedBox(height: 16),
          Text(
            '시간대 생성 중...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (provider.bulkCreationTotal > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${provider.bulkCreationProgress} / ${provider.bulkCreationTotal}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: provider.bulkCreationProgress / provider.bulkCreationTotal,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜 범위',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: '시작 날짜',
                date: _startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: '종료 날짜',
                date: _endDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(DateFormatter.formatDate(date)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운영 시간',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeField(
                label: '시작 시간',
                time: _startTime,
                onTap: () => _selectTime(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeField(
                label: '종료 시간',
                time: _endTime,
                onTap: () => _selectTime(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(time.format(context)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '슬롯 지속시간 (분)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _durationController,
          label: '지속시간 (분)',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '지속시간을 입력해주세요';
            }
            final duration = int.tryParse(value);
            if (duration == null || duration < 30 || duration > 480) {
              return '30분에서 8시간(480분) 사이로 입력해주세요';
            }
            return null;
          },
          onChanged: (value) {
            final duration = int.tryParse(value);
            if (duration != null) {
              _slotDurationMinutes = duration;
            }
          },
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '타입',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            RadioListTile<SlotType>(
              title: const Text('워크샵'),
              value: SlotType.workshop,
              groupValue: _slotType,
              onChanged: (value) {
                setState(() {
                  _slotType = value!;
                  if (_slotType == SlotType.space) {
                    _selectedWorkshopId = null;
                  }
                });
              },
            ),
            RadioListTile<SlotType>(
              title: const Text('공간 대관'),
              value: SlotType.space,
              groupValue: _slotType,
              onChanged: (value) {
                setState(() {
                  _slotType = value!;
                  if (_slotType == SlotType.space) {
                    _selectedWorkshopId = null;
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkshopSection() {
    if (_slotType != SlotType.workshop) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '워크샵 선택',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Consumer<TimeSlotProvider>(
          builder: (context, provider, child) {
            return DropdownButtonFormField<String>(
              value: _selectedWorkshopId,
              decoration: const InputDecoration(
                hintText: '워크샵을 선택하세요',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('워크샵 선택 안함'),
                ),
                ...provider.workshops.map((workshop) {
                  return DropdownMenuItem<String>(
                    value: workshop.id,
                    child: Text(workshop.title),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedWorkshopId = value;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최대 수용인원',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _capacityController,
          label: '최대 수용인원',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '최대 수용인원을 입력해주세요';
            }
            final capacity = int.tryParse(value);
            return TimeSlot.validateCapacity(capacity);
          },
          onChanged: (value) {
            final capacity = int.tryParse(value);
            if (capacity != null) {
              _maxCapacity = capacity;
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '가격 (선택사항)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '워크샵의 기본 가격을 덮어쓰려면 입력하세요',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _priceController,
          label: '가격 (원)',
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _price = double.tryParse(value);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdaySection() {
    const weekdays = [
      {'value': 1, 'label': '월'},
      {'value': 2, 'label': '화'},
      {'value': 3, 'label': '수'},
      {'value': 4, 'label': '목'},
      {'value': 5, 'label': '금'},
      {'value': 6, 'label': '토'},
      {'value': 0, 'label': '일'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '제외할 요일',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: weekdays.map((weekday) {
            final isExcluded = _excludeWeekdays.contains(weekday['value']);
            return FilterChip(
              label: Text(weekday['label'] as String),
              selected: isExcluded,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _excludeWeekdays.add(weekday['value'] as int);
                  } else {
                    _excludeWeekdays.remove(weekday['value']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Consumer<TimeSlotProvider>(
              builder: (context, provider, child) {
                return AppButton(
                  text: '생성',
                  onPressed: provider.isBulkCreating ? null : _createBulkTimeSlots,
                  isLoading: provider.isBulkCreating,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 7));
          }
        }
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _createBulkTimeSlots() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate time range
    final timeError = TimeSlot.validateTimeRange(_startTime, _endTime);
    if (timeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(timeError)),
      );
      return;
    }

    final provider = context.read<TimeSlotProvider>();
    final success = await provider.createBulkTimeSlots(
      startDate: _startDate,
      endDate: _endDate,
      startTime: _startTime,
      endTime: _endTime,
      slotDurationMinutes: _slotDurationMinutes,
      maxCapacity: _maxCapacity,
      type: _slotType,
      itemId: _selectedWorkshopId,
      price: _price,
      excludeWeekdays: _excludeWeekdays.toList(),
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}