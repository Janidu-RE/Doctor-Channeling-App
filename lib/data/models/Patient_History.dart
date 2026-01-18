import 'package:mongo_dart/mongo_dart.dart';

class PatientHistory {
  ObjectId? id;
  ObjectId patientId;
  List<String> history;
  List<String> allergies;

  PatientHistory({
    this.id,
    required this.patientId,
    required this.history,
    required this.allergies,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'patientId': patientId,
      'history': history,
      'allergies': allergies,
    };
  }

  factory PatientHistory.fromMap(Map<String, dynamic> map) {
    return PatientHistory(
      id: map['_id'] as ObjectId?,
      patientId: map['patientId'] as ObjectId,
      history: List<String>.from(map['history'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
    );
  }

  void addAllergy(String allergy) {
    allergies.add(allergy);
  }
}
