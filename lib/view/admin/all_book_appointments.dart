import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:flutter/material.dart';

class AllAppointmentsScreen extends StatefulWidget {
  const AllAppointmentsScreen({super.key});

  @override
  State<AllAppointmentsScreen> createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen> {
  String _filter = 'all';

  Stream<QuerySnapshot> _getAppointmentsStream() {
    return FirebaseFirestore.instance.collection('appointments').snapshots();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        title: const Text('All Appointments'),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ✅ Filter Chips
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _filter == 'all',
                      color: AppColors.adminColor,
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pending',
                      isSelected: _filter == 'pending',
                      color: Colors.orange,
                      onTap: () => setState(() => _filter = 'pending'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Completed',
                      isSelected: _filter == 'completed',
                      color: Colors.green,
                      onTap: () => setState(() => _filter = 'completed'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Cancelled',
                      isSelected: _filter == 'cancelled',
                      color: Colors.red,
                      onTap: () => setState(() => _filter = 'cancelled'),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Appointments List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getAppointmentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 64,
                            color: AppColors.adminColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Koi appointment nahi',
                            style: AppStyles.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter
                  var docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (_filter == 'all') return true;
                    return data['status'] == _filter;
                  }).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        '$_filter appointments nahi hain',
                        style: AppStyles.bodyMedium,
                      ),
                    );
                  }

                  // ✅ Stats
                  final total = snapshot.data!.docs.length;
                  final pending = snapshot.data!.docs
                      .where((d) => (d.data() as Map)['status'] == 'pending')
                      .length;
                  final completed = snapshot.data!.docs
                      .where((d) => (d.data() as Map)['status'] == 'completed')
                      .length;
                  final cancelled = snapshot.data!.docs
                      .where((d) => (d.data() as Map)['status'] == 'cancelled')
                      .length;

                  return Column(
                    children: [
                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _StatBox(
                              label: 'Total',
                              value: '$total',
                              color: AppColors.adminColor,
                            ),
                            const SizedBox(width: 8),
                            _StatBox(
                              label: 'Pending',
                              value: '$pending',
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _StatBox(
                              label: 'Done',
                              value: '$completed',
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _StatBox(
                              label: 'Cancelled',
                              value: '$cancelled',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),

                      // List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final status = data['status'] ?? 'pending';
                            final date = data['date'] != null
                                ? (data['date'] as Timestamp).toDate()
                                : DateTime.now();

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
                                  // Patient & Doctor
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person_outline,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  data['patientName'] ??
                                                      'Patient',
                                                  style: AppStyles.heading3,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .medical_services_outlined,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Dr. ${data['doctorName'] ?? ''}',
                                                  style: AppStyles.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Status Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                            status,
                                          ).withOpacity(0.1),
                                          borderRadius:
                                              AppStyles.borderRadiusSmall,
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: _statusColor(status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 6),

                                  // Specialist
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_hospital_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        data['specialist'] ?? '',
                                        style: AppStyles.bodyMedium.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Date
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                        style: AppStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Fee
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'PKR ${data['fee'] ?? '0'}/-',
                                        style: AppStyles.bodyMedium.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Phone
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        data['patientPhone'] ?? 'N/A',
                                        style: AppStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Reason
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.note_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          data['reason'] ?? '',
                                          style: AppStyles.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: AppStyles.borderRadiusMedium,
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Stat Box
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
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
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: AppStyles.heading2.copyWith(color: color)),
            Text(label, style: AppStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
