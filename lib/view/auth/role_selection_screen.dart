import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:flutter/material.dart';

/// Role Selection Screen - First screen users see
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // App Logo / Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppStyles.borderRadiusLarge,
                ),
                child: const Icon(
                  Icons.local_hospital_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              Text('MediBook', style: AppStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'Your trusted doctor appointment\nbooking platform',
                style: AppStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              Text('Continue as', style: AppStyles.heading3),
              const SizedBox(height: 24),

              // Patient Card
              _RoleCard(
                title: 'Patient',
                subtitle: 'Book appointments with doctors',
                icon: Icons.person_outline,
                color: AppColors.patientColor,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/login',
                  arguments: 'patient',
                ),
              ),

              const SizedBox(height: 16),

              // Doctor Card
              _RoleCard(
                title: 'Doctor',
                subtitle: 'Manage your appointments & schedule',
                icon: Icons.medical_services_outlined,
                color: AppColors.doctorColor,
                onTap: () =>
                    Navigator.pushNamed(context, '/login', arguments: 'doctor'),
              ),

              const SizedBox(height: 16),

              // Admin Card
              _RoleCard(
                title: 'Admin',
                subtitle: 'Manage system and users',
                icon: Icons.admin_panel_settings_outlined,
                color: AppColors.adminColor,
                onTap: () =>
                    Navigator.pushNamed(context, '/login', arguments: 'admin'),
              ),

              // ✅ Spacer NAHI - SizedBox use karein
              const SizedBox(height: 40),

              Text('MediBook v1.0.0', style: AppStyles.bodySmall),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Role Selection Card Widget
class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppStyles.borderRadiusLarge,
          border: Border.all(color: AppColors.border),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppStyles.borderRadiusMedium,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),

            // Text
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

            // Arrow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppStyles.borderRadiusSmall,
              ),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
