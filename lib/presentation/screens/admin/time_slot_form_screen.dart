import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/time_slot_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../core/utils/date_formatter.dart';

class TimeSlotFormScreen extends StatefulWidget {
  final TimeSlot? timeSlot;
  final bool isEditing;

  const TimeSlotFormScreen({
    super.key,
    this.timeSlot,
    this.isEditing = false,
  });

  @override
  State<TimeSlotFormScreen> createState() => _TimeSlotFormScreenState();
}

class _TimeSlotFormScreenState extends State<TimeSlotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late SlotType _slotType;
  String? _selectedWorkshopId;
  late int _maxCapacity;
  double? _price;
  late bool _isAvailable;

  // Controllers
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.timeSlot != null) {
      final slot = widget.timeSlot!;
      _selectedDate = slot.date;
      _startTime = slot.startTime;
      _endTime = slot.endTime;
      _slotType = slot.type;
      _selectedWorkshopId = slot.itemId;
      _maxCapacity = slot.maxCapacity;
      _price = slot.price;
      _isAvailable = slot.isAvailable;
      
      _capacityController.text = _maxCapacity.toString();
      _priceController.text = _price?.toString() ?? '';
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
      _slotType = SlotType.workshop;
      _maxCapacity = 10;
      _isAvailable = true;
      
      _capacityController.text = _maxCapacity.toString();
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '시간대 수정' : '시간대 생성'),
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobile: _buildForm(),
        tablet: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Consumer<TimeSlotProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: LoadingWidget());
        }

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildTimeSection(),
              const SizedBox(height: 24),
              _buildTypeSection(),
              const SizedBox(height: 24),
              _buildWorkshopSection(),
              const SizedBox(height: 24),
              _buildCapacitySection(),
              const SizedBox(height: 24),
              _buildPriceSection(),
              const SizedBox(height: 24),
              _buildAvailabilitySection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
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

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '날짜',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(DateFormatter.formatDate(_selectedDate)),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시간',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            Text(
              '지속시간: ${_getDurationText()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
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
                const Icon(Icons.access_time),
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

  Widget _buildTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '타입',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
        ),
      ),
    );
  }

  Widget _buildWorkshopSection() {
    if (_slotType != SlotType.workshop) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '워크샵 선택',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
                  validator: _slotType == SlotType.workshop
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '워크샵을 선택해주세요';
                          }
                          return null;
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최대 수용인원',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
            if (widget.isEditing && widget.timeSlot != null) ...[
              const SizedBox(height: 8),
              Text(
                '현재 예약: ${widget.timeSlot!.currentBookings}명',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '가격 (선택사항)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '워크샵의 기본 가격을 덮어쓰려면 입력하세요',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _priceController,
              label: '가격 (원)',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _price = double.tryParse(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예약 가능 여부',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '비활성화하면 사용자가 예약할 수 없습니다',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: widget.isEditing ? '수정' : '생성',
            onPressed: _saveTimeSlot,
          ),
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

  String _getDurationText() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final durationMinutes = endMinutes - startMinutes;
    
    if (durationMinutes <= 0) {
      return '유효하지 않음';
    }
    
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}시간 ${minutes}분';
    } else if (hours > 0) {
      return '${hours}시간';
    } else {
      return '${minutes}분';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
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

  Future<void> _saveTimeSlot() async {
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

    // Validate date
    final dateError = TimeSlot.validateDate(_selectedDate);
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateError)),
      );
      return;
    }

    final timeSlot = TimeSlot(
      id: widget.timeSlot?.id ?? '',
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      type: _slotType,
      itemId: _selectedWorkshopId,
      isAvailable: _isAvailable,
      maxCapacity: _maxCapacity,
      currentBookings: widget.timeSlot?.currentBookings ?? 0,
      price: _price,
      createdAt: widget.timeSlot?.createdAt ?? DateTime.now(),
    );

    final provider = context.read<TimeSlotProvider>();
    bool success;

    if (widget.isEditing) {
      success = await provider.updateTimeSlot(timeSlot);
    } else {
      success = await provider.createTimeSlot(timeSlot);
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}