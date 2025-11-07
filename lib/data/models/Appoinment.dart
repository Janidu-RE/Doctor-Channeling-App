class Appointment {
  String appointment_id;
  DateTime date;
  DateTime time;
  String status;

  Appointment({
    required this.appointment_id,
    required this.date,
    required this.time,
    required this.status,
  });

  void changeStatus(String newStatus) {
    status = newStatus;
  }
}
