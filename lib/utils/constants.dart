class Constants {
  // Local MongoDB for Android Emulator (10.0.2.2 points to host localhost)
  static const String MONGO_CONN_URL = "mongodb://10.0.2.2:27017/doctor_channeling";
  
  // Collections
  static const String USERS_COLLECTION = "users";
  static const String DOCTORS_COLLECTION = "doctors"; 
  static const String APPOINTMENTS_COLLECTION = "appointments";
  static const String PATIENTS_HISTORY_COLLECTION = "patient_history";
}
