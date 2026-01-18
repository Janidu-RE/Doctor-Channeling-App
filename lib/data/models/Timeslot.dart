import 'package:mongo_dart/mongo_dart.dart';

class Timeslot {
  ObjectId? id;
  ObjectId doctorId;
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
      '_id': id,
      'doctorId': doctorId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'capacity': capacity,
      'bookedCount': bookedCount,
    };
  }

  factory Timeslot.fromMap(Map<String, dynamic> map) {
    return Timeslot(
      id: map['_id'] as ObjectId?,
      doctorId: map['doctorId'] as ObjectId,
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      capacity: map['capacity'] ?? 1,
      bookedCount: map['bookedCount'] ?? 0,
    );
  }
}
