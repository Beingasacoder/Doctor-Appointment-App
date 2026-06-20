import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/model/doctor_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _selectedDay = 'Monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  List<Map<String, dynamic>> _slots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final doctorVM = context.read<DoctorViewModel>();
    final stream = doctorVM.getAvailabilityStream();
    stream.first.then((slots) {
      setState(() => _slots = slots);
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _addSlot() async {
    // Validate
    if (_startTime.hour > _endTime.hour ||
        (_startTime.hour == _endTime.hour &&
            _startTime.minute >= _endTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time start time se baad honi chahiye!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Duplicate check
    final exists = _slots.any(
      (s) =>
          s['day'] == _selectedDay &&
          s['startTime'] == _formatTime(_startTime) &&
          s['endTime'] == _formatTime(_endTime),
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeh slot pehle se exist karta hai!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newSlot = {
      'id': const Uuid().v4(),
      'day': _selectedDay,
      'startTime': _formatTime(_startTime),
      'endTime': _formatTime(_endTime),
      'isBooked': false,
    };

    setState(() => _slots.add(newSlot));
  }

  Future<void> _saveSlots() async {
    setState(() => _isLoading = true);
    final doctorVM = context.read<DoctorViewModel>();
    final error = await doctorVM.saveAvailability(_slots);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Availability successfully save ho gayi! ✅'),
          backgroundColor: error != null ? Colors.red : Colors.green,
        ),
      );
    }
  }

  void _deleteSlot(String id) {
    setState(() => _slots.removeWhere((s) => s['id'] == id));
  }

  @override
  Widget build(BuildContext context) {
    // Group slots by day
    final Map<String, List<Map<String, dynamic>>> groupedSlots = {};
    for (final slot in _slots) {
      final day = slot['day'] as String;
      groupedSlots.putIfAbsent(day, () => []).add(slot);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.doctorColor,
        foregroundColor: Colors.white,
        title: const Text('My Availability'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSlots,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Add Slot Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppStyles.borderRadiusLarge,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppStyles.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Naya Slot Add Karein', style: AppStyles.heading3),
                    const SizedBox(height: 16),

                    // Day Selector
                    Text('Din Select Karein', style: AppStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppStyles.borderRadiusMedium,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDay,
                          isExpanded: true,
                          items: _days
                              .map(
                                (day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(day),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedDay = val!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Time Row
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time', style: AppStyles.bodyMedium),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime,
                                  );
                                  if (picked != null) {
                                    setState(() => _startTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.doctorColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: AppStyles.borderRadiusMedium,
                                    border: Border.all(
                                      color: AppColors.doctorColor.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: AppColors.doctorColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(_startTime),
                                        style: AppStyles.heading3.copyWith(
                                          color: AppColors.doctorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // End Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Time', style: AppStyles.bodyMedium),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _endTime,
                                  );
                                  if (picked != null) {
                                    setState(() => _endTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: AppStyles.borderRadiusMedium,
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(_endTime),
                                        style: AppStyles.heading3.copyWith(
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addSlot,
                        icon: const Icon(Icons.add),
                        label: const Text('Slot Add Karein'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.doctorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppStyles.borderRadiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ Slots List
              Text('Mere Available Slots', style: AppStyles.heading3),
              const SizedBox(height: 12),

              if (_slots.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppStyles.borderRadiusLarge,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 48,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Koi slot nahi — upar se add karein',
                        style: AppStyles.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                ...groupedSlots.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Header
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.doctorColor,
                          borderRadius: AppStyles.borderRadiusSmall,
                        ),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Slots
                      ...entry.value.map((slot) {
                        final isBooked = slot['isBooked'] as bool? ?? false;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.red.withOpacity(0.05)
                                : Colors.green.withOpacity(0.05),
                            borderRadius: AppStyles.borderRadiusMedium,
                            border: Border.all(
                              color: isBooked
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isBooked
                                    ? Icons.event_busy_outlined
                                    : Icons.event_available_outlined,
                                color: isBooked ? Colors.red : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${slot['startTime']} — ${slot['endTime']}',
                                  style: AppStyles.heading3,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: AppStyles.borderRadiusSmall,
                                ),
                                child: Text(
                                  isBooked ? 'Booked' : 'Available',
                                  style: TextStyle(
                                    color: isBooked ? Colors.red : Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (!isBooked)
                                IconButton(
                                  onPressed: () => _deleteSlot(slot['id']),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                    ],
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
