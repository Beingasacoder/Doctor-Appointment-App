import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/view/service/notifecation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? doctorData;
  bool isLoading = false;

  // ✅ Doctor ki apni info
  Stream<DocumentSnapshot> getDoctorStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // ✅ orderBy hata diya — index ki zaroorat nahi ab
  Stream<QuerySnapshot> getMyAppointmentsStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .snapshots();
  }

  // ✅ Today appointments — sirf doctorId filter, date Dart mein check karo
  Stream<QuerySnapshot> getTodayAppointmentsStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .snapshots(); // ✅ Date filter hata diya
  }

  // ✅ Appointment status update
Future<String?> updateAppointmentStatus(
  String appointmentId,
  String status,
) async {
  try {
    // Appointment data lo
    final doc = await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .get();
    final data = doc.data() as Map<String, dynamic>;
    final patientId = data['patientId'] ?? '';
    final date = data['date'] != null
        ? (data['date'] as Timestamp).toDate()
        : DateTime.now();
    final dateStr =
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    // Doctor name lo
    final uid = _auth.currentUser!.uid;
    final doctorDoc =
        await _firestore.collection('users').doc(uid).get();
    final doctorName =
        (doctorDoc.data() as Map<String, dynamic>)['name'] ?? 'Doctor';

    // Status update karo
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status});

    // ✅ Patient ko notify karo
    if (patientId.isNotEmpty) {
      await NotificationService.notifyPatientOnStatus(
        patientId: patientId,
        doctorName: doctorName,
        status: status,
        date: dateStr,
      );
    }

    return null;
  } catch (e) {
    return 'Error: ${e.toString()}';
  }
}

  // ✅ Total unique patients
  Stream<int> getTotalPatientsCount() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final patientIds = snapshot.docs
              .map((doc) => doc['patientId'])
              .toSet();
          return patientIds.length;
        });
  }

  // ✅ Doctor apni availability save kare
  Future<String?> saveAvailability(List<Map<String, dynamic>> slots) async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'availability': slots,
      });
      return null;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ✅ Doctor ki availability fetch karo
  Stream<List<Map<String, dynamic>>> getAvailabilityStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      final availability = data['availability'] as List<dynamic>? ?? [];
      return availability.map((e) => e as Map<String, dynamic>).toList();
    });
  }

  // ✅ Slot booked mark karo
  Future<String?> markSlotBooked(String slotId) async {
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data() as Map<String, dynamic>;
      final availability = (data['availability'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final updated = availability.map((slot) {
        if (slot['id'] == slotId) {
          return {...slot, 'isBooked': true};
        }
        return slot;
      }).toList();

      await _firestore.collection('users').doc(uid).update({
        'availability': updated,
      });
      return null;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
  

  // ✅ Kisi bhi doctor ki availability fetch karo (patient ke liye)
  Future<List<Map<String, dynamic>>> getDoctorAvailability(
    String doctorId,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(doctorId).get();
      final data = doc.data() as Map<String, dynamic>;
      final availability = data['availability'] as List<dynamic>? ?? [];
      return availability.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }
}
