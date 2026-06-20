import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart';
import 'package:doctorapp/view/admin/add_doctor_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllDoctorsScreen extends StatefulWidget {
  const AllDoctorsScreen({super.key});

  @override
  State<AllDoctorsScreen> createState() => _AllDoctorsScreenState();
}

class _AllDoctorsScreenState extends State<AllDoctorsScreen> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    final authVM = context.read<AuthViewModel>();
    final doctors = await authVM.getAllDoctors();
    setState(() {
      _doctors = doctors;
      _isLoading = false;
    });
  }

  Future<void> _deleteDoctor(String uid, String name) async {
    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('$name ko delete karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authVM = context.read<AuthViewModel>();
      final error = await authVM.deleteUser(uid);
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      } else {
        _loadDoctors();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor delete ho gaya!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.doctorColor,
        foregroundColor: Colors.white,
        title: const Text('All Doctors'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDoctors),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.doctorColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDoctorScreen()),
          );
          _loadDoctors(); // Refresh after adding
        },
        child: const Icon(Icons.person_add_outlined),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: AppColors.doctorColor.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text('No Doctor Found', style: AppStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddDoctorScreen(),
                      ),
                    ),
                    child: const Text('Add Doctor'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDoctors,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return _DoctorCard(
                    doctor: doctor,
                    onDelete: () => _deleteDoctor(
                      doctor['uid'] ?? '',
                      doctor['name'] ?? 'Doctor',
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onDelete;

  const _DoctorCard({required this.doctor, required this.onDelete});

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
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.doctorColor.withOpacity(0.1),
              borderRadius: AppStyles.borderRadiusMedium,
            ),
            child: Icon(
              Icons.medical_services_outlined,
              color: AppColors.doctorColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor['name'] ?? 'Unknown', style: AppStyles.heading3),
                const SizedBox(height: 4),
                Text(doctor['email'] ?? '', style: AppStyles.bodyMedium),
                // Email ke neeche specialist show karo
                Text(
                  doctor['specialist'] ?? 'General Physician',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.doctorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
