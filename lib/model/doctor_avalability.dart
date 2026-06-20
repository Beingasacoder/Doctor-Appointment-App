class TimeSlot {
  final String id;
  final String day; // 'Monday', 'Tuesday', etc.
  final String startTime; // '09:00'
  final String endTime; // '10:00'
  bool isBooked;

  TimeSlot({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
    'isBooked': isBooked,
  };

  factory TimeSlot.fromMap(Map<String, dynamic> map) => TimeSlot(
    id: map['id'],
    day: map['day'],
    startTime: map['startTime'],
    endTime: map['endTime'],
    isBooked: map['isBooked'] ?? false,
  );
}
