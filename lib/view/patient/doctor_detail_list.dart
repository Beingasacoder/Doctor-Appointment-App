import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/view/patient/book_apportment.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/custom_button.dart';

/// Doctor Detail Screen
class DoctorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  const DoctorDetailScreen({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Doctor Image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: AppStyles.borderRadiusSmall,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(doctorData['name'],
                        style: AppStyles.heading3
                            .copyWith(color: Colors.white)),
                    Text(doctorData['specialization'],
                        style: AppStyles.bodyMedium
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _StatCard(
                          icon: Icons.star,
                          value: '${doctorData['rating']}',
                          label: 'Rating',
                          color: const Color(0xFFF59E0B)),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: Icons.work_outline,
                          value: '${doctorData['experience']}+',
                          label: 'Years Exp',
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: Icons.people_outline,
                          value: '200+',
                          label: 'Patients',
                          color: AppColors.secondary),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  Text('About', style: AppStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    'Dr. ${doctorData['name']} is a highly experienced ${doctorData['specialization']} with ${doctorData['experience']} years of practice. Specializing in advanced diagnosis and patient-centered care.',
                    style: AppStyles.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Consultation Fee
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: AppStyles.borderRadiusMedium,
                      border: Border.all(
                          color: AppColors.secondary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Consultation Fee',
                            style: AppStyles.bodyLarge),
                        Text(
                          'Rs. ${doctorData['fee']}',
                          style: AppStyles.heading3
                              .copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Availability
                  Text('Available Days', style: AppStyles.heading3),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                        .map((day) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: AppStyles.borderRadiusMedium,
                              ),
                              child: Text(day,
                                  style: AppStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 32),

                  // Book Button
                  CustomButton(
                    text: 'Book Appointment',
                    icon: Icons.calendar_month_outlined,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookAppointmentScreen(
                            doctorData: doctorData),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppStyles.borderRadiusMedium,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: AppStyles.heading3.copyWith(color: color)),
            Text(label, style: AppStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}