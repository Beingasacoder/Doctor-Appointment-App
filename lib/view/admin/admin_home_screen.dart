import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart';
import 'package:doctorapp/view/admin/add_doctor_screen.dart';
import 'package:doctorapp/view/admin/all_book_appointments.dart';
import 'package:doctorapp/view/admin/all_doctor_screen.dart';
import 'package:doctorapp/view/admin/all_patient_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.adminColor, Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppStyles.borderRadiusLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome Admin!',
                      style: AppStyles.heading2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage doctors, patients & system',
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Doctors',
                      icon: Icons.medical_services_outlined,
                      color: AppColors.doctorColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Patients',
                      icon: Icons.people_outline,
                      color: AppColors.patientColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Bookings',
                      icon: Icons.calendar_month_outlined,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text('Quick Actions', style: AppStyles.heading3),
              const SizedBox(height: 16),

              // ✅ Add Doctor
              _ActionTile(
                title: 'Add New Doctor',
                subtitle: 'Register a new doctor to the system',
                icon: Icons.person_add_outlined,
                color: AppColors.doctorColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDoctorScreen()),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ View Doctors - FIXED
              _ActionTile(
                title: 'View All Doctors',
                subtitle: 'See and manage registered doctors',
                icon: Icons.medical_services_outlined,
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllDoctorsScreen()),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ View Patients - FIXED
              _ActionTile(
                title: 'View All Patients',
                subtitle: 'See and manage registered patients',
                icon: Icons.people_outline,
                color: AppColors.patientColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllPatientsScreen()),
                ),
              ),

              const SizedBox(height: 12),

              // View Appointments
              _ActionTile(
                title: 'All Appointments',
                subtitle: 'View all booked appointments',
                icon: Icons.calendar_month_outlined,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllAppointmentsScreen(),
                  ), // ✅
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Stats Card
class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppStyles.borderRadiusLarge,
        border: Border.all(color: AppColors.border),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppStyles.borderRadiusSmall,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }
}

// Action Tile
class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppStyles.borderRadiusLarge,
          border: Border.all(color: AppColors.border),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppStyles.borderRadiusMedium,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.heading3),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppStyles.bodyMedium),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
