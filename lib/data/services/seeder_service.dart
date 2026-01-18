import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Doctor.dart';

class SeederService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedDoctors() async {
    try {
      // Check if doctors collection is empty
      final snapshot = await _db.collection('doctors').limit(1).get();
      
      if (snapshot.docs.isNotEmpty) {
        print("Seeder: Doctors already exist. Skipping.");
        return; 
      }

      print("Seeder: No doctors found. Seeding dummy data...");

      List<Doctor> dummyDoctors = [
        Doctor(
          username: "Dr. Smith",
          password: "password", // Dummy
          email: "smith@hospital.com",
          contactNo: "0771234567",
          speciality: "Cardiology",
          bio: "Expert in heart health with 15 years of experience.",
          rating: 4.8,
          experience: 15,
          consultationFee: 2500.0,
          imageUrl: "assets/images/doctor_placeholder_1768657364775.png"
        ),
        Doctor(
          username: "Dr. Anne",
          password: "password",
          email: "anne@hospital.com",
          contactNo: "0777654321",
          speciality: "Dermatology",
          bio: "Specialist in skin care and cosmetic treatments.",
          rating: 4.9,
          experience: 8,
          consultationFee: 2000.0,
          imageUrl: "assets/images/doctor_placeholder_1768762954932.png"
        ),
         Doctor(
          username: "Dr. Perera",
          password: "password",
          email: "perera@hospital.com",
          contactNo: "0712345678",
          speciality: "Neurology",
          bio: "Leading neurologist specializing in brain disorders.",
          rating: 4.7,
          experience: 12,
          consultationFee: 3000.0,
          imageUrl: "assets/images/doctor_placeholder_1768657364775.png"
        ),
        Doctor(
          username: "Dr. Fernando",
          password: "password",
          email: "fernando@hospital.com",
          contactNo: "0755555555",
          speciality: "Pediatric",
          bio: "Caring pediatrician for your little ones.",
          rating: 4.9,
          experience: 10,
          consultationFee: 1800.0,
           imageUrl: "assets/images/doctor_placeholder_1768762954932.png"
        ),
        Doctor(
          username: "Dr. Jayasinghe",
          password: "password",
          email: "jayasinghe@hospital.com",
          contactNo: "0766666666",
          speciality: "General",
          bio: "General physician for all your family needs.",
          rating: 4.5,
          experience: 20,
          consultationFee: 1500.0,
           imageUrl: "assets/images/doctor_placeholder_1768657364775.png"
        ),
      ];

      for (var doc in dummyDoctors) {
        // Create a new document reference to get an ID
        DocumentReference ref = _db.collection('doctors').doc();
        doc.id = ref.id; // Set the ID in the model
        await ref.set(doc.toMap());
        print("Seeded: ${doc.username}");
      }
      
      print("Seeder: Doctor seeding complete.");

    } catch (e) {
      print("Seeder Error: $e");
    }
  }
}
