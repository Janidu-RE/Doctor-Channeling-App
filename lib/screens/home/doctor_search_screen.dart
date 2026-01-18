import 'package:flutter/material.dart';
import '../../data/services/mongo_database.dart';
import '../../data/models/Doctor.dart';
import '../doctor/doctor_detail_screen.dart';


class DoctorSearchScreen extends StatefulWidget {
  final String? category; // Optional category filter
  const DoctorSearchScreen({super.key, this.category});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  
  @override
  Widget build(BuildContext context) {
    // Construct query based on category
    final Map<String, dynamic> filter = {'role': 'doctor'};
    if (widget.category != null && widget.category!.isNotEmpty && widget.category != "General") {
      // Simple regex for "contains" or exact match. For now, exact match on speciality is safer if data is clean.
       filter['speciality'] = widget.category;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.category ?? "All Doctors")),
      body: FutureBuilder(
        future: MongoDatabase.doctorCollection.find(filter).toList(), 
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          final doctorsData = snapshot.data as List;
          if (doctorsData.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                Text("No ${widget.category ?? ""} Doctors Found", style: const TextStyle(color: Colors.grey)),
              ],
            ));
          }
    
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctorsData.length,
            itemBuilder: (context, index) {
              final doc = Doctor.fromMap(doctorsData[index]);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: Hero(
                     tag: 'doctor_list_${doc.id}',
                     child: Container(
                       width: 60, height: 60,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         image: DecorationImage(image: AssetImage(doc.imageUrl), fit: BoxFit.cover),
                       ),
                     ),
                  ),
                  title: Text("Dr. ${doc.username}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.speciality, style: const TextStyle(color: Colors.blue)),
                      const SizedBox(height: 5),
                      Text("Fee: \$${doc.consultationFee}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doc)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
