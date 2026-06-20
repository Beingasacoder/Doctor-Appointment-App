import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/model/doctor_view_model.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart'; // ✅
import 'package:doctorapp/view/common/notifecation_screen.dart';
import 'package:doctorapp/view/doctor/doctor_avalibility_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardTab(),
      const _AppointmentsTab(),
      const DoctorAvailabilityScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.doctorColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.event_available_outlined),
            label: 'availability',
          ),
        ],
      ),
      appBar: AppBar(
        actions: [
          // AppBar actions mein
          IconButton(
            icon: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where(
                    'userId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                );
              },
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Dashboard Tab
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final doctorVM = context.watch<DoctorViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return SafeArea(
      child: Column(
        children: [
          // ✅ Header - Real Time
          StreamBuilder<DocumentSnapshot>(
            stream: doctorVM.getDoctorStream(),
            builder: (context, snapshot) {
              String name = 'Doctor';
              String email = '';
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                name = data['name'] ?? 'Doctor';
                email = data['specialist'] ?? '';
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.doctorColor, Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppStyles.borderRadiusMedium,
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. $name',
                            style: AppStyles.heading2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            email,
                            style: AppStyles.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await authVM.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ✅ Stats - Real Time
                  StreamBuilder<QuerySnapshot>(
                    stream: doctorVM.getMyAppointmentsStream(),
                    builder: (context, snapshot) {
                      int total = 0, pending = 0, completed = 0;
                      if (snapshot.hasData) {
                        final docs = snapshot.data!.docs;
                        total = docs.length;
                        pending = docs
                            .where(
                              (d) => (d.data() as Map)['status'] == 'pending',
                            )
                            .length;
                        completed = docs
                            .where(
                              (d) => (d.data() as Map)['status'] == 'completed',
                            )
                            .length;
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              label: 'Total',
                              value: '$total',
                              icon: Icons.calendar_month_outlined,
                              color: AppColors.doctorColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Pending',
                              value: '$pending',
                              icon: Icons.hourglass_empty,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Done',
                              value: '$completed',
                              icon: Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ✅ Today Appointments
                  Text(
                    "${doctorVM.doctorData?['name'] ?? 'Doctor'}'s Appointments",
                    style: AppStyles.heading3,
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: doctorVM.getTodayAppointmentsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _EmptyBox(message: 'No appointments found');
                      }

                      // ✅ Today filter hatao — sari pending appointments dikhao
                      final pendingDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final hidden = data['hiddenFromDoctor'] ?? false;
                        return data['status'] == 'pending' && hidden == false;
                      }).toList();

                      if (pendingDocs.isEmpty) {
                        return _EmptyBox(
                          message: 'Koi pending appointment nahi',
                        );
                      }

                      return Column(
                        children: pendingDocs.map((doc) {
                          return _AppointmentCard(
                            doc: doc,
                            doctorVM: doctorVM,
                            showActions: true,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Appointments Tab — Sari Appointments Filter ke saath
class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab();

  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final doctorVM = context.watch<DoctorViewModel>();

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.doctorColor,
            child: Text(
              'All Appointments',
              style: AppStyles.heading2.copyWith(color: Colors.white),
            ),
          ),
          // AppBar actions mein
          IconButton(
            icon: const Icon(Icons.schedule, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DoctorAvailabilityScreen(),
              ),
            ),
          ),

          // ✅ Filter Tabs
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                  color: AppColors.doctorColor,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: _filter == 'pending',
                  onTap: () => setState(() => _filter = 'pending'),
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  isSelected: _filter == 'completed',
                  onTap: () => setState(() => _filter = 'completed'),
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cancelled',
                  isSelected: _filter == 'cancelled',
                  onTap: () => setState(() => _filter = 'cancelled'),
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // ✅ Appointments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: doctorVM.getMyAppointmentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptyBox(message: 'No appointments found');
                }

                // Filter apply karo
                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (_filter == 'all') return true;
                  return data['status'] == _filter;
                }).toList();

                if (docs.isEmpty) {
                  return _EmptyBox(message: 'No $_filter appointments found');
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _AppointmentCard(
                      doc: docs[index],
                      doctorVM: doctorVM,
                      showActions:
                          (docs[index].data() as Map)['status'] == 'pending',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Appointment Card
class _AppointmentCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final DoctorViewModel doctorVM;
  final bool showActions;

  const _AppointmentCard({
    required this.doc,
    required this.doctorVM,
    required this.showActions,
  });

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
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'pending';
    final patientName = data['patientName'] ?? 'Patient';
    final date = data['date'] != null
        ? (data['date'] as Timestamp).toDate()
        : DateTime.now();
    final reason = data['reason'] ?? 'General Checkup';
    final fee = data['fee'] ?? '0';

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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.patientColor.withOpacity(0.1),
                  borderRadius: AppStyles.borderRadiusMedium,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.patientColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: AppStyles.heading3),
                    Text(reason, style: AppStyles.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: AppStyles.borderRadiusSmall,
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

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

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
              const Icon(Icons.attach_money, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'PKR $fee/-',
                style: AppStyles.bodyMedium.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ✅ Phone Number
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(data['patientPhone'] ?? 'N/A', style: AppStyles.bodyMedium),
              const Spacer(),
              // ✅ Call Button
              GestureDetector(
                onTap: () {
                  // Call feature baad mein add karein
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: AppStyles.borderRadiusSmall,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.call, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Call',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ✅ Action Buttons
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final error = await doctorVM.updateAppointmentStatus(
                        doc.id,
                        'cancelled',
                      );
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                      }
                    },
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final error = await doctorVM.updateAppointmentStatus(
                        doc.id,
                        'completed',
                      );
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                      }
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
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

// ✅ Stat Box
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppStyles.heading1.copyWith(color: color)),
          Text(label, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ✅ Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

// ✅ Empty Box
class _EmptyBox extends StatelessWidget {
  final String message;
  const _EmptyBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Icons.calendar_month_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(message, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }
}
