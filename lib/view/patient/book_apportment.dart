import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/custom_button.dart';

/// Book Appointment Screen
class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const BookAppointmentScreen({super.key, required this.doctorData});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isBooking = false;

  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  ];

  // Booked slots - Firebase se aayega
  final List<String> _bookedSlots = ['09:30 AM', '11:00 AM'];

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time on date change
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time slot'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);
    await Future.delayed(const Duration(seconds: 2)); // Firebase call
    setState(() => _isBooking = false);

    if (mounted) {
      // Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: AppStyles.borderRadiusXL),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Appointment Booked!',
                  style: AppStyles.heading3, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Your appointment with ${widget.doctorData['name']} on ${DateFormat('MMM dd, yyyy').format(_selectedDate!)} at $_selectedTime has been booked.',
                style: AppStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Done',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Book Appointment', style: AppStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppStyles.borderRadiusLarge,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: AppStyles.borderRadiusMedium,
                    ),
                    child: const Icon(Icons.person,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.doctorData['name'],
                          style: AppStyles.heading3),
                      Text(widget.doctorData['specialization'],
                          style: AppStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
                      Text('Fee: Rs. ${widget.doctorData['fee']}',
                          style: AppStyles.bodySmall
                              .copyWith(color: AppColors.secondary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Select Date
            Text('Select Date', style: AppStyles.heading3),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppStyles.borderRadiusLarge,
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.primary
                        : AppColors.border,
                    width: _selectedDate != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: _selectedDate != null
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEEE, MMM dd yyyy')
                              .format(_selectedDate!)
                          : 'Tap to select date',
                      style: AppStyles.bodyLarge.copyWith(
                        color: _selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.textHint),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Time Slots
            Text('Select Time Slot', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text('Green = Available  |  Grey = Booked',
                style: AppStyles.bodySmall),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (_, i) {
                final slot = _timeSlots[i];
                final isBooked = _bookedSlots.contains(slot);
                final isSelected = slot == _selectedTime;

                return GestureDetector(
                  onTap: isBooked
                      ? null
                      : () => setState(() => _selectedTime = slot),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isBooked
                          ? AppColors.divider
                          : isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                      borderRadius: AppStyles.borderRadiusMedium,
                      border: Border.all(
                        color: isBooked
                            ? AppColors.border
                            : isSelected
                                ? AppColors.primary
                                : AppColors.border,
                      ),
                    ),
                    child: Text(
                      slot,
                      style: AppStyles.bodySmall.copyWith(
                        color: isBooked
                            ? AppColors.textHint
                            : isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        decoration: isBooked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Confirm Button
            CustomButton(
              text: 'Confirm Appointment',
              onPressed: _bookAppointment,
              isLoading: _isBooking,
              icon: Icons.check_circle_outline,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}