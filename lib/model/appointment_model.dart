/// Appointment Model - Firestore Collection: appointments
class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime date;
  final String timeSlot;
  final String
  status; // 'pending', 'confirmed', 'rejected', 'cancelled', 'completed'
  final String? notes;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialization: map['doctorSpecialization'] ?? '',
      date: DateTime.parse(map['date']),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
      notes: map['notes'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  AppointmentModel copyWith({String? status, String? notes}) {
    return AppointmentModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      date: date,
      timeSlot: timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  /// Check if appointment is upcoming
  bool get isUpcoming =>
      date.isAfter(DateTime.now()) &&
      status != 'cancelled' &&
      status != 'rejected';

  /// Check if appointment is past
  bool get isPast => date.isBefore(DateTime.now()) || status == 'completed';
}
