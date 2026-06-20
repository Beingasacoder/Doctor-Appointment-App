import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// My Appointments Screen
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data - Firebase se replace hoga
  final List<Map<String, dynamic>> _upcoming = [
    {
      'doctor': 'Dr. Ahmed Khan',
      'specialization': 'Cardiologist',
      'date': DateTime.now().add(const Duration(days: 2)),
      'time': '10:00 AM',
      'status': 'confirmed',
    },
    {
      'doctor': 'Dr. Sara Ali',
      'specialization': 'Neurologist',
      'date': DateTime.now().add(const Duration(days: 5)),
      'time': '02:30 PM',
      'status': 'pending',
    },
  ];

  final List<Map<String, dynamic>> _past = [
    {
      'doctor': 'Dr. Bilal Rashid',
      'specialization': 'Pediatrician',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'time': '11:00 AM',
      'status': 'completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('My Appointments', style: AppStyles.heading3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentList(
              appointments: _upcoming, isUpcoming: true),
          _AppointmentList(
              appointments: _past, isUpcoming: false),
        ],
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final bool isUpcoming;

  const _AppointmentList(
      {required this.appointments, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming
                  ? Icons.calendar_month_outlined
                  : Icons.history,
              size: 60,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming appointments'
                  : 'No past appointments',
              style: AppStyles.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (_, i) {
        final apt = appointments[i];
        return _AppointmentCard(
            appointment: apt, isUpcoming: isUpcoming);
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isUpcoming;

  const _AppointmentCard(
      {required this.appointment, required this.isUpcoming});

  Color get _statusColor {
    switch (appointment['status']) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppStyles.borderRadiusMedium,
                    ),
                    child: const Icon(Icons.person,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment['doctor'],
                          style: AppStyles.heading3),
                      Text(appointment['specialization'],
                          style: AppStyles.bodyMedium),
                    ],
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: AppStyles.borderRadiusMedium,
                ),
                child: Text(
                  appointment['status'].toString().toUpperCase(),
                  style: AppStyles.bodySmall.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20, color: AppColors.divider),

          // Date & Time
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, MMM dd yyyy')
                    .format(appointment['date']),
                style: AppStyles.bodySmall,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(appointment['time'], style: AppStyles.bodySmall),
            ],
          ),

          // Action Buttons (only for upcoming)
          if (isUpcoming) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Cancel appointment
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppStyles.borderRadiusMedium),
                    ),
                    child: Text('Cancel',
                        style: AppStyles.bodySmall
                            .copyWith(color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Reschedule
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppStyles.borderRadiusMedium),
                      elevation: 0,
                    ),
                    child: Text('Reschedule',
                        style: AppStyles.bodySmall
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}