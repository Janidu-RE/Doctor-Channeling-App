import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import '../../utils/constants.dart';

class MongoDatabase {
  static var db, userCollection, doctorCollection, appointmentCollection;

  static connect() async {
    try {
      db = await Db.create(Constants.MONGO_CONN_URL);
      await db.open();
      inspect(db);
      userCollection = db.collection(Constants.USERS_COLLECTION);
      doctorCollection = db.collection(Constants.DOCTORS_COLLECTION);
      appointmentCollection = db.collection(Constants.APPOINTMENTS_COLLECTION);
      log("MongoDB Connection Successful");
    } catch (e) {
      log("MongoDB Connection Failed: $e");
    }
  }
}
