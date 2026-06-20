import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/view/patient/doctor_detail_list.dart';
import 'package:flutter/material.dart';

/// Doctor List Screen with Search & Filter
class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _searchController = TextEditingController();
  String _selectedSpecialization = 'All';

  final List<String> _specializations = [
    'All', 'Cardiologist', 'Neurologist',
    'Pediatrician', 'Orthopedic', 'Eye Specialist',
  ];

  // Dummy doctor data - Firebase se replace hoga
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'Dr. Ahmed Khan',
      'specialization': 'Cardiologist',
      'rating': 4.8,
      'experience': 10,
      'fee': 1500,
      'isAvailable': true,
    },
    {
      'id': '2',
      'name': 'Dr. Sara Ali',
      'specialization': 'Neurologist',
      'rating': 4.9,
      'experience': 8,
      'fee': 2000,
      'isAvailable': true,
    },
    {
      'id': '3',
      'name': 'Dr. Bilal Rashid',
      'specialization': 'Pediatrician',
      'rating': 4.7,
      'experience': 6,
      'fee': 1200,
      'isAvailable': false,
    },
    {
      'id': '4',
      'name': 'Dr. Ayesha Malik',
      'specialization': 'Eye Specialist',
      'rating': 4.6,
      'experience': 12,
      'fee': 1800,
      'isAvailable': true,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _doctors.where((d) {
      final matchSearch = d['name']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchSpec = _selectedSpecialization == 'All' ||
          d['specialization'] == _selectedSpecialization;
      return matchSearch && matchSpec;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Find Doctors', style: AppStyles.heading3),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search + Filter
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search doctor name...',
                    hintStyle: AppStyles.bodyMedium,
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textHint),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textHint),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: AppStyles.borderRadiusLarge,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 12),

                // Specialization Filter Chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specializations.length,
                    itemBuilder: (_, i) {
                      final spec = _specializations[i];
                      final selected = spec == _selectedSpecialization;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedSpecialization = spec),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: AppStyles.borderRadiusLarge,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            spec,
                            style: AppStyles.bodySmall.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} Doctors Found',
                  style: AppStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Doctor List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 60, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text('No doctors found',
                            style: AppStyles.bodyLarge),
                        Text('Try different search terms',
                            style: AppStyles.bodyMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final doctor = _filtered[i];
                      return _DoctorCard(
                        doctor: doctor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorDetailScreen(doctorData: doctor),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Doctor List Card
class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Doctor Avatar
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppStyles.borderRadiusMedium,
                  ),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 36),
                ),
                // Available Badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: doctor['isAvailable']
                          ? AppColors.success
                          : AppColors.textHint,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor['name'], style: AppStyles.heading3),
                  const SizedBox(height: 4),
                  Text(doctor['specialization'],
                      style: AppStyles.bodyMedium
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFF59E0B), size: 14),
                      const SizedBox(width: 4),
                      Text('${doctor['rating']}',
                          style: AppStyles.bodySmall
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      const Icon(Icons.work_outline,
                          color: AppColors.textHint, size: 14),
                      const SizedBox(width: 4),
                      Text('${doctor['experience']} yrs',
                          style: AppStyles.bodySmall),
                      const SizedBox(width: 10),
                      Text('Rs. ${doctor['fee']}',
                          style: AppStyles.bodySmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}