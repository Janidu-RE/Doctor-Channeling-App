import 'package:mongo_dart/mongo_dart.dart';

class Appointment {
  ObjectId? id;
  ObjectId doctorId;
  ObjectId patientId;
  DateTime date;
  String status;

  Appointment({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['_id'] as ObjectId?,
      doctorId: map['doctorId'] as ObjectId,
      patientId: map['patientId'] as ObjectId,
      date: DateTime.parse(map['date']),
      status: map['status'] ?? 'pending',
    );
  }
}
