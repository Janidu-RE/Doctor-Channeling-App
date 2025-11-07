
class Patient_History {
  String history_id;
  List<String> history;
  List<String> allergies;

  Patient_History({
    required this.history_id,
    required this.history,
    required this.allergies,
  });

  void addAllergies(String allergy) {
    allergies.add(allergy);
  }
}
