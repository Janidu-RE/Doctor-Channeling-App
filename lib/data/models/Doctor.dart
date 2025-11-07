import 'user.dart';

class Doctor extends User {
  String doctor_id;
  String speciality;

  Doctor({

    required super.user_id,
    required super.username,
    required super.password,
    required super.email,
    required super.contactNo,

    required this.doctor_id,
    required this.speciality,
  });

  void viewAppointment() {
  }

  void viewPatientHistory() {
  }

  void addPatientHistory() {
  }

  void notifyAdminAvailability() {
  }
}
