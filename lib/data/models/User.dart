import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId? id;
  String username;
  String password;
  String email;
  String contactNo;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.contactNo,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'password': password,
      'email': email,
      'contactNo': contactNo,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as ObjectId?,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      contactNo: map['contactNo'] ?? '',
    );
  }
}
