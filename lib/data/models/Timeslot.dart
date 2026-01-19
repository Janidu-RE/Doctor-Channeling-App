class Timeslot {
  String? id;
  String doctorId;
  DateTime startTime;
  DateTime endTime;
  int capacity;
  int bookedCount;

  Timeslot({
    this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.bookedCount = 0,
  });

  bool get isAvailable => bookedCount < capacity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'capacity': capacity,
      'bookedCount': bookedCount,
    };
  }

  factory Timeslot.fromMap(Map<String, dynamic> map) {
    return Timeslot(
      id: map['id'] ?? map['_id']?.toString(),
      doctorId: map['doctorId']?.toString() ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      capacity: map['capacity'] ?? 1,
      bookedCount: map['bookedCount'] ?? 0,
    );
  }
}
