import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart';
import 'package:doctorapp/view%20model/patient_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const _HomeTab(), const _AppointmentsTab()];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
        ],
      ),
    );
  }
}

// ✅ Home Tab
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _searchQuery = '';
  String _selectedSpecialist = 'All';

  final List<String> _specializations = [
    'All',
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Gynecologist',
    'ENT Specialist',
    'Ophthalmologist',
    'Dentist',
  ];

  @override
  Widget build(BuildContext context) {
    final patientVM = context.watch<PatientViewModel>();
    final authVM = context.read<AuthViewModel>();

    return SafeArea(
      child: Column(
        children: [
          // ✅ Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: patientVM.getPatientStream(),
                      builder: (context, snapshot) {
                        String name = 'Patient';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          name =
                              (snapshot.data!.data()
                                  as Map<String, dynamic>)['name'] ??
                              'Patient';
                        }
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $name! 👋',
                                style: AppStyles.heading2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Book your appointment today',
                                style: AppStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () async {
                        await authVM.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppStyles.borderRadiusMedium,
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search for doctors...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: AppStyles.borderRadiusMedium,
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Specialist Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _specializations.length,
                      itemBuilder: (context, index) {
                        final spec = _specializations[index];
                        final isSelected = _selectedSpecialist == spec;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSpecialist = spec),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: AppStyles.borderRadiusMedium,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              spec,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text('Available Doctors', style: AppStyles.heading3),
                  const SizedBox(height: 12),

                  // ✅ Doctors List - Real Time
                  StreamBuilder<QuerySnapshot>(
                    stream: patientVM.getAllDoctorsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('no doctor matches your criteria'),
                        );
                      }

                      // Filter by search & specialist
                      var docs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] ?? '').toLowerCase();
                        final spec = data['specialist'] ?? 'General Physician';
                        final matchSearch =
                            _searchQuery.isEmpty ||
                            name.contains(_searchQuery.toLowerCase());
                        final matchSpec =
                            _selectedSpecialist == 'All' ||
                            spec == _selectedSpecialist;
                        return matchSearch && matchSpec;
                      }).toList();

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text('no doctor matches your criteria'),
                        );
                      }

                      return Column(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _DoctorCard(doctorId: doc.id, data: data);
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

// ✅ Doctor Card
class _DoctorCard extends StatelessWidget {
  final String doctorId;
  final Map<String, dynamic> data;

  const _DoctorCard({required this.doctorId, required this.data});

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
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.doctorColor.withOpacity(0.1),
                  borderRadius: AppStyles.borderRadiusMedium,
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  color: AppColors.doctorColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${data['name'] ?? ''}',
                      style: AppStyles.heading3,
                    ),
                    Text(
                      data['specialist'] ?? 'General Physician',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data['experience'] ?? '0'} years exp',
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Fee
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PKR ${data['fee'] ?? '0'}',
                    style: AppStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text('per visit', style: AppStyles.bodySmall),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Book Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showBookingDialog(context, data),
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppStyles.borderRadiusMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, Map<String, dynamic> data) {
    final reasonController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    List<Map<String, dynamic>> availableSlots = [];
    Map<String, dynamic>? selectedSlot;
    bool slotsLoading = true;

    // Doctor ki availability fetch karo
    FirebaseFirestore.instance.collection('users').doc(doctorId).get().then((
      doc,
    ) {
      if (doc.exists) {
        final docData = doc.data() as Map<String, dynamic>;
        final slots = (docData['availability'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .where((s) => !(s['isBooked'] as bool? ?? false))
            .toList();
        availableSlots = slots;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          // Load slots
          if (slotsLoading) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(doctorId)
                .get()
                .then((doc) {
                  if (doc.exists) {
                    final docData = doc.data() as Map<String, dynamic>;
                    final slots =
                        (docData['availability'] as List<dynamic>? ?? [])
                            .map((e) => e as Map<String, dynamic>)
                            .where((s) => !(s['isBooked'] as bool? ?? false))
                            .toList();
                    setModalState(() {
                      availableSlots = slots;
                      slotsLoading = false;
                    });
                  } else {
                    setModalState(() => slotsLoading = false);
                  }
                });
          }

          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Book Appointment', style: AppStyles.heading2),
                  const SizedBox(height: 4),
                  Text(
                    'Dr. ${data['name']} — ${data['specialist']}',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Available Slots Section
                  Text('Available Slots', style: AppStyles.heading3),
                  const SizedBox(height: 8),

                  if (slotsLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (availableSlots.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: AppStyles.borderRadiusMedium,
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Is doctor ne abhi koi slot set nahi kiya — date/time manually select karein',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSlots.map((slot) {
                        final isSelected = selectedSlot?['id'] == slot['id'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => selectedSlot = slot);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.green.withOpacity(0.08),
                              borderRadius: AppStyles.borderRadiusMedium,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.green.withOpacity(0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  slot['day'] ?? '',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.green[700],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${slot['startTime']} - ${slot['endTime']}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // ✅ Date Picker
                  Text('Date Select Karein', style: AppStyles.bodyMedium),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppStyles.borderRadiusMedium,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: AppStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✅ Reason
                  Text('Reason / Symptoms', style: AppStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Masalan: Bukhar, Sir dard, etc.',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: AppStyles.borderRadiusMedium,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppStyles.borderRadiusMedium,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Fee Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: AppStyles.borderRadiusMedium,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Consultation Fee: PKR ${data['fee'] ?? '0'}/-',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (reasonController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reason likhein')),
                          );
                          return;
                        }

                        // Slot select check
                        if (availableSlots.isNotEmpty && selectedSlot == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Koi slot select karein!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Time determine karo
                        TimeOfDay appointmentTime = const TimeOfDay(
                          hour: 10,
                          minute: 0,
                        );
                        if (selectedSlot != null) {
                          final timeParts =
                              (selectedSlot!['startTime'] as String).split(':');
                          appointmentTime = TimeOfDay(
                            hour: int.parse(timeParts[0]),
                            minute: int.parse(timeParts[1]),
                          );
                        }

                        final appointmentDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          appointmentTime.hour,
                          appointmentTime.minute,
                        );

                        final patientVM = context.read<PatientViewModel>();
                        final error = await patientVM.bookAppointment(
                          doctorId: doctorId,
                          doctorName: data['name'] ?? '',
                          specialist: data['specialist'] ?? '',
                          fee: '${data['fee'] ?? 0}',
                          date: appointmentDate,
                          reason: reasonController.text.trim(),
                          slotId: selectedSlot?['id'],
                          slotInfo: selectedSlot != null
                              ? '${selectedSlot!['day']} ${selectedSlot!['startTime']}-${selectedSlot!['endTime']}'
                              : null,
                        );

                        // ✅ Slot booked mark karo Firestore mein
                        if (error == null && selectedSlot != null) {
                          final slots = availableSlots.map((s) {
                            if (s['id'] == selectedSlot!['id']) {
                              return {...s, 'isBooked': true};
                            }
                            return s;
                          }).toList();

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(doctorId)
                              .update({'availability': slots});
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error ?? 'Appointment book ho gayi! ✅',
                              ),
                              backgroundColor: error != null
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppStyles.borderRadiusMedium,
                        ),
                      ),
                      child: const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ✅ Appointments Tab
class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

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
    final patientVM = context.read<PatientViewModel>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.primary,
            child: Text(
              'My Appointments',
              style: AppStyles.heading2.copyWith(color: Colors.white),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: patientVM.getMyAppointmentsStream(),
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
                          color: AppColors.primary.withOpacity(0.3),
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
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
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.doctorColor.withOpacity(0.1),
                                  borderRadius: AppStyles.borderRadiusMedium,
                                ),
                                child: Icon(
                                  Icons.medical_services_outlined,
                                  color: AppColors.doctorColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. ${data['doctorName'] ?? ''}',
                                      style: AppStyles.heading3,
                                    ),
                                    Text(
                                      data['specialist'] ?? '',
                                      style: AppStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
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
                          Row(
                            children: [
                              const Icon(
                                Icons.note_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                data['reason'] ?? '',
                                style: AppStyles.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
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
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // ✅ Cancel Button (sirf pending pe)
                          if (status == 'pending') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Cancel Appointment'),
                                      content: const Text(
                                        'Appointment cancel karna chahte hain?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Nahi'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Haan',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && context.mounted) {
                                    await patientVM.cancelAppointment(doc.id);
                                  }
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Cancel Appointment',
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
