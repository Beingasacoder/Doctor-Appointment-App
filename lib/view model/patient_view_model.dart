import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorapp/view/service/notifecation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Patient ki apni info
  Stream<DocumentSnapshot> getPatientStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // ✅ Sare doctors real time
  Stream<QuerySnapshot> getAllDoctorsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots();
  }

  // ✅ Search doctors by specialist
  Stream<QuerySnapshot> getDoctorsBySpecialist(String specialist) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('specialist', isEqualTo: specialist)
        .snapshots();
  }

  // ✅ Patient ke appointments
  Stream<QuerySnapshot> getMyAppointmentsStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .orderBy('date', descending: false)
        .snapshots();
  }

  // ✅ Pehle sirf doctorId se lo, phir Dart mein filter karo
  Stream<QuerySnapshot> getTodayAppointmentsStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .snapshots();
  }

  // ✅ Appointment book karo
  Future<String?> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String specialist,
    required String fee,
    required DateTime date,
    required String reason,
    String? slotId,
    String? slotInfo,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;
      final patientDoc = await _firestore.collection('users').doc(uid).get();
      final patientName = patientDoc['name'] ?? 'Patient';
      final patientPhone = patientDoc['phone'] ?? 'N/A';

      final dateStr =
          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

      await _firestore.collection('appointments').add({
        'patientId': uid,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'specialist': specialist,
        'fee': fee,
        'date': Timestamp.fromDate(date),
        'reason': reason,
        'slotId': slotId,
        'slotInfo': slotInfo,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Doctor ko notify karo
      await NotificationService.notifyDoctorOnBooking(
        doctorId: doctorId,
        patientName: patientName,
        date: dateStr,
        reason: reason,
      );

      return null;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ✅ Appointment cancel karo
  Future<String?> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
      });
      return null;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
