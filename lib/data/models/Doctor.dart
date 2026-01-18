import 'package:mongo_dart/mongo_dart.dart';
import 'User.dart';

class Doctor extends User {
  String speciality;
  String bio;
  double rating;
  int experience; // years
  String imageUrl; // path to asset or network url
  double consultationFee;

  Doctor({
    super.id,
    required super.username,
    required super.password,
    required super.email,
    required super.contactNo,
    required this.speciality,
    this.bio = "Experienced specialist dedicated to patient care.",
    this.rating = 4.5,
    this.experience = 5,
    this.imageUrl = "assets/images/doctor_placeholder_1768762954932.png", // Default placeholder
    this.consultationFee = 50.0,
  });

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['speciality'] = speciality;
    map['bio'] = bio;
    map['rating'] = rating;
    map['experience'] = experience;
    map['imageUrl'] = imageUrl;
    map['consultationFee'] = consultationFee;
    map['role'] = 'doctor';
    return map;
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['_id'] as ObjectId?,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      contactNo: map['contactNo'] ?? '',
      speciality: map['speciality'] ?? '',
      bio: map['bio'] ?? "Experienced specialist dedicated to patient care.",
      rating: (map['rating'] ?? 4.5).toDouble(),
      experience: map['experience'] ?? 5,
      imageUrl: map['imageUrl'] ?? "assets/images/doctor_placeholder_1768762954932.png",
      consultationFee: (map['consultationFee'] ?? 50.0).toDouble(),
    );
  }
}
