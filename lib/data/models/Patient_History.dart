class PatientHistory {
  String? id;
  String patientId;
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
      'id': id,
      'patientId': patientId,
      'history': history,
      'allergies': allergies,
    };
  }

  factory PatientHistory.fromMap(Map<String, dynamic> map) {
    return PatientHistory(
      id: map['id'] ?? map['_id']?.toString(),
      patientId: map['patientId']?.toString() ?? '',
      history: List<String>.from(map['history'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
    );
  }

  void addAllergy(String allergy) {
    allergies.add(allergy);
  }
}
