import 'user.dart';

class Patient extends User {
  String patient_id;
  DateTime birthday;
  String address;

  Patient({
    required super.user_id,
    required super.username,
    required super.password,
    required super.email,
    required super.contactNo,

    required this.patient_id,
    required this.birthday,
    required this.address,
  });

  void registerUser() {
  }

  void updateUser() {
  }

  void createAppointment() {
  }

  void modifyAppointment() {
  }

  void cancelAppointment() {
  }

  void viewAppointment() {
  }
}
