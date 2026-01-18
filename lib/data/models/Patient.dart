import 'User.dart';

class Patient extends User {
  DateTime birthday;
  String address;

  Patient({
    super.id,
    required super.username,
    required super.password,
    required super.email,
    required super.contactNo,
    required this.birthday,
    required this.address,
  });

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['birthday'] = birthday.toIso8601String();
    map['address'] = address;
    map['role'] = 'patient';
    return map;
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? map['_id']?.toString(),
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      contactNo: map['contactNo'] ?? '',
      birthday: DateTime.parse(map['birthday']),
      address: map['address'] ?? '',
    );
  }
}
