import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/firebase_service.dart';
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

    return await FirebaseService.getPatientHistory(user.id!);
  }

  Future<void> _addAllergy() async {
    String? allergy = await showDialog<String>(
      context: context,
      builder: (context) {
        String value = '';
        return AlertDialog(
          title: const Text('Add Allergy'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g., Peanuts, Penicillin'),
            onChanged: (v) => value = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, value),
              child: const Text('Add'),
            ),
          ],
        );
      }
    );

    if (allergy != null && allergy.isNotEmpty) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        await FirebaseService.addPatientAllergy(user.id!, allergy);
        setState(() {}); // Refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50], // Light background
      body: FutureBuilder(
        future: _fetchHistory(),
        builder: (context, AsyncSnapshot<PatientHistory?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final history = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade800]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text("Your Medical Records", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                       SizedBox(height: 5),
                       Text("Keep track of your health journey.", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Allergies Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Allergies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _addAllergy,
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text("Add"),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                if (history != null && history.allergies.isNotEmpty)
                  ...history.allergies.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red.shade100)),
                    child: ListTile(
                      title: Text(a, style: const TextStyle(fontWeight: FontWeight.w600)),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      ),
                    ),
                  )).toList()
                else
                  _buildEmptyState("No allergies recorded."),
                  
                const SizedBox(height: 30),
                
                // Notes Section
                const Text("History & Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                if (history != null && history.history.isNotEmpty)
                  ...history.history.map((h) => Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                       contentPadding: const EdgeInsets.all(15),
                      title: Text(h, style: const TextStyle(height: 1.5, color: Colors.black87)),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.article_outlined, color: Colors.blue),
                      ),
                    ),
                  )).toList()
                else
                   _buildEmptyState("No history notes recorded."),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
