import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../data/services/mongo_database.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/Patient_History.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {

  Future<PatientHistory?> _fetchHistory() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user.id == null) return null;

    final data = await MongoDatabase.db.collection('patient_history').findOne(
      mongo.where.eq('patientId', user.id)
    );

    if (data != null) {
      return PatientHistory.fromMap(data);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchHistory(),
      builder: (context, AsyncSnapshot<PatientHistory?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Even if no history record, we might want to show "No History Recorded"
        final history = snapshot.data;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text("Medical Allergies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (history != null && history.allergies.isNotEmpty)
              ...history.allergies.map((a) => ListTile(title: Text(a), leading: const Icon(Icons.warning, color: Colors.amber))).toList()
            else
              const Text("No allergies recorded."),
              
            const Divider(height: 32),
            
            const Text("Medical History / Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (history != null && history.history.isNotEmpty)
              ...history.history.map((h) => ListTile(title: Text(h), leading: const Icon(Icons.notes))).toList()
            else
              const Text("No history notes recorded."),
          ],
        );
      },
    );
  }
}
