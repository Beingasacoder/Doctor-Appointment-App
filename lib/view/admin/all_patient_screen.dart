import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllPatientsScreen extends StatefulWidget {
  const AllPatientsScreen({super.key});

  @override
  State<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    final authVM = context.read<AuthViewModel>();
    final patients = await authVM.getAllPatients();
    setState(() {
      _patients = patients;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.patientColor,
        foregroundColor: Colors.white,
        title: const Text('All Patients'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPatients),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.patientColor.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text('Koi patient nahi mila', style: AppStyles.bodyMedium),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPatients,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  final patient = _patients[index];
                  return _PatientCard(patient: patient);
                },
              ),
            ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const _PatientCard({required this.patient});

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
              color: AppColors.patientColor.withOpacity(0.1),
              borderRadius: AppStyles.borderRadiusMedium,
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.patientColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient['name'] ?? 'Unknown', style: AppStyles.heading3),
                const SizedBox(height: 4),
                Text(patient['email'] ?? '', style: AppStyles.bodyMedium),
                if (patient['phone'] != null) ...[
                  const SizedBox(height: 2),
                  Text(patient['phone'], style: AppStyles.bodySmall),
                ],
              ],
            ),
          ),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.patientColor.withOpacity(0.1),
              borderRadius: AppStyles.borderRadiusSmall,
            ),
            child: Text(
              'Patient',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.patientColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
