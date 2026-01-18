import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/User.dart';
import '../models/Doctor.dart';
import '../models/Patient.dart';
import '../models/Appointment.dart';
import '../models/Patient_History.dart';

class FirebaseService {
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Authentication ---

  static Future<User?> loginUser(String email, String password) async {
    try {
      auth.UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (credential.user != null) {
        return await getUser(credential.user!.uid);
      }
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
    return null;
  }

  static Future<User?> registerUser(User user) async {
    try {
      // 1. Create Auth User
      auth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: user.email, 
        password: user.password
      );

      if (credential.user != null) {
        String uid = credential.user!.uid;
        user.id = uid;

        // 2. Save to Firestore
        // Determine collection based on role (or type check)
        String collection = 'users'; // default
        if (user is Doctor) {
          collection = 'doctors';
        } else if (user is Patient) {
          collection = 'patients'; // or just users with role? The app seems to separate them based on mongo usage
          // Let's stick to separate collections 'doctors' and 'users' (patients) for now to match Mongo logic if possible
          // Or separate 'doctors' and 'patients'
        }
        
        // However, MongoDatabase.dart used 'users' for generic login? 
        // Let's check how saving was done. 
        // Actually, let's just save based on runtime type for now. 
        // If it's a Doctor, save to 'doctors'. If Patient, save to 'users' or 'patients'.
        // To keep it simple and consistent with previous "users" logic, maybe we split them.
        // But for login to work easily, we might want a unified 'users' collection or search both?
        // Let's assume:
        // Doctors -> 'doctors'
        // Patients -> 'users' (generic)
        
        // Wait, MongoDatabase had doctorCollection and userCollection. 
        // Let's use 'doctors' and 'users'.
        
        if (user is Doctor) {
           await _db.collection('doctors').doc(uid).set(user.toMap());
        } else {
           await _db.collection('users').doc(uid).set(user.toMap());
        }

        return user;
      }
    } catch (e) {
      print("Registration Error: $e");
      rethrow;
    }
    return null;
  }
  
  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<User?> getUser(String uid) async {
    // Try finding in users first
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      var data = doc.data()!;
      data['id'] = doc.id;
      return Patient.fromMap(data); // Assuming users are patients
    }
    
    // Try doctors
    doc = await _db.collection('doctors').doc(uid).get();
    if (doc.exists) {
       var data = doc.data()!;
       data['id'] = doc.id;
       return Doctor.fromMap(data);
    }
    
    return null;
  }

  // --- Doctors ---

  static Future<List<Doctor>> getDoctors({String? category, String? query}) async {
    Query q = _db.collection('doctors');
    
    // Firestore exact match for category
    if (category != null && category != "All") {
      // NOTE: Firestore regex is not supported directly. 
      // We must handle "fuzzy" category logic either client side or via array-contains if we added tags.
      // For now, let's try strict equality or startAt/endAt for simple prefix.
      
      // The previous fuzzy logic mapped "Cardiology" to "Cardio".
      // Firestore doesn't do regex. 
      // We'll filter CLIENT SIDE for the complex regex scenarios if dataset is small, 
      // or just strict match if we don't want to load all.
      // Given it's a demo, fetching all doctors and filtering in Dart is safer for regex support.
      // But let's try to filter by equality if exact match, else fetch all.
    }
    
    // Fetch all for now to support the complex regex/search filters on client side 
    // because Firestore query capabilities are limited compared to Mongo regex.
    final snapshot = await q.get();
    
    List<Doctor> doctors = snapshot.docs.map((d) {
      var data = d.data() as Map<String, dynamic>;
      data['id'] = d.id;
      return Doctor.fromMap(data);
    }).toList();

    // Apply Client-Side Filtering to match previous robust logic
    if (category != null && category != "All") {
      String pattern = category;
       switch (category) {
        case "Cardiology": pattern = "Cardio"; break;
        case "Dermatology": pattern = "Derma"; break;
        case "Skin": pattern = "Skin|Derma"; break;
        case "Eye": pattern = "Eye|Opth"; break;
        case "Neurology": pattern = "Neuro"; break;
        case "Pediatric": pattern = "Pediat"; break;
        case "General": pattern = "General"; break;
      }
      final regex = RegExp(pattern, caseSensitive: false);
      doctors = doctors.where((d) => regex.hasMatch(d.speciality)).toList();
    }

    if (query != null && query.isNotEmpty) {
       final regex = RegExp(query, caseSensitive: false);
       doctors = doctors.where((d) => regex.hasMatch(d.username)).toList();
    }

    return doctors;
  }
  
  static Future<Doctor?> getDoctorById(String id) async {
    final doc = await _db.collection('doctors').doc(id).get();
    if (doc.exists) {
       var data = doc.data()!;
       data['id'] = doc.id;
       return Doctor.fromMap(data);
    }
    return null;
  }

  // --- Appointments ---

  static Future<void> bookAppointment(Appointment appointment) async {
    // We let Firestore generate ID if new, or use existing if provided (but usually doc() creates auto id)
    // Appointment object might have null ID.
    
    DocumentReference ref = _db.collection('appointments').doc(); // Auto Id
    appointment.id = ref.id;
    appointment.createdAt = DateTime.now(); // Set creation time
    
    await ref.set(appointment.toMap());
  }

  static Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await _db.collection('appointments').doc(id).update(data);
  }
  
  static Future<void> cancelAppointment(String id) async {
    await _db.collection('appointments').doc(id).update({'status': 'cancelled'});
  }

  static Future<List<Map<String, dynamic>>> getEnrichedAppointments(String patientId) async {
    // 1. Get Appointments
    final snapshot = await _db.collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();

    List<Appointment> appointments = snapshot.docs.map((d) {
      var data = d.data();
      data['id'] = d.id;
      return Appointment.fromMap(data);
    }).toList();
    
    // Sort logic? 
    // If user wants "Last added first", standard Firestore IDs are somewhat random (not time ordered like Mongo).
    // I will sort by 'date' for utility, or just reverse order?
    // Let's just return list.

    // Sort by createdAt descending (Newest first)
    appointments.sort((a, b) {
       DateTime timeA = a.createdAt ?? DateTime(2000);
       DateTime timeB = b.createdAt ?? DateTime(2000);
       return timeB.compareTo(timeA);
    });

    List<Map<String, dynamic>> enriched = [];
    
    for (var appt in appointments) {
       var doctor = await getDoctorById(appt.doctorId);
       enriched.add({
         'appointment': appt,
         'doctor': doctor,
         'doctorName': doctor?.username ?? "Unknown"
       });
    }
    
    return enriched;
  }

  // --- Patient History ---

  static Future<PatientHistory?> getPatientHistory(String patientId) async {
    final snapshot = await _db.collection('patient_history').where('patientId', isEqualTo: patientId).get();
    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data();
      data['id'] = snapshot.docs.first.id;
      return PatientHistory.fromMap(data);
    }
    return null;
  }

  static Future<void> addPatientAllergy(String patientId, String allergy) async {
    final snapshot = await _db.collection('patient_history').where('patientId', isEqualTo: patientId).get();
    
    if (snapshot.docs.isNotEmpty) {
      // Update existing
      await _db.collection('patient_history').doc(snapshot.docs.first.id).update({
        'allergies': FieldValue.arrayUnion([allergy])
      });
    } else {
      // Create new
      var newHistory = PatientHistory(
        patientId: patientId,
        history: [],
        allergies: [allergy]
      );
      DocumentReference ref = _db.collection('patient_history').doc();
      newHistory.id = ref.id;
      await ref.set(newHistory.toMap());
    }
  }
}
