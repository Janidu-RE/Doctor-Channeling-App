class Appointment {
  String? id;
  String doctorId;
  String patientId;
  DateTime date;
  String status;
  DateTime? createdAt;

  Appointment({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    this.status = 'pending',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? map['_id']?.toString(), // Handle both
      doctorId: map['doctorId']?.toString() ?? '', // Ensure string
      patientId: map['patientId']?.toString() ?? '', // Ensure string
      date: DateTime.parse(map['date']),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}
