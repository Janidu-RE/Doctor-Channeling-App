class Timeslot {
  String time_slot_id;
  DateTime startTime;
  DateTime endTime;
  int capacity;

  Timeslot({
    required this.time_slot_id,
    required this.startTime,
    required this.endTime,
    required this.capacity,
  });

  void remainingPatient() {
  }
}
