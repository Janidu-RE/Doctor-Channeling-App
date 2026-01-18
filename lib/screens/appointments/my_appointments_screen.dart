import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/services/mongo_database.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/Appointment.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../data/models/Doctor.dart';
import '../booking/book_appointment_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  
  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user.id == null) return [];
    
    // Find appointments for this patient, sorted by creation time (newest first)
    final rawAppointments = await MongoDatabase.appointmentCollection.find(
      mongo.where.eq('patientId', user.id).sortBy('_id', descending: true)
    ).toList();

    List<Map<String, dynamic>> enrichedList = [];

    for (var apptMap in rawAppointments) {
      final appt = Appointment.fromMap(apptMap);
      final doctorMap = await MongoDatabase.doctorCollection.findOne(mongo.where.id(appt.doctorId));
      
      Doctor? doctor;
      if (doctorMap != null) {
        doctor = Doctor.fromMap(doctorMap);
      }

      enrichedList.add({
        'appointment': appt,
        'doctor': doctor, // Store full object
        'doctorName': doctor != null ? doctor.username : "Unknown"
      });
    }

    return enrichedList;
  }

  Future<void> _cancelAppointment(mongo.ObjectId id) async {
    await MongoDatabase.appointmentCollection.update(
      mongo.where.id(id),
      mongo.modify.set('status', 'cancelled')
    );
    setState(() {}); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Appointments")),
      backgroundColor: Colors.grey[50], // Light bg
      body: FutureBuilder(
        future: _fetchAppointments(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text("No Appointments Found", style: TextStyle(color: Colors.grey, fontSize: 18))
              ],
            ));
          }
  
          final enrichedData = snapshot.data as List<Map<String, dynamic>>;
  
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enrichedData.length,
            itemBuilder: (context, index) {
              final item = enrichedData[index];
              final appt = item['appointment'] as Appointment;
              final doctorName = item['doctorName'] as String;
              final doctor = item['doctor'] as Doctor?;

              final isPending = appt.status == 'pending';
              final isCancelled = appt.status == 'cancelled';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: const Icon(Icons.medical_services, color: Colors.blue),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dr. $doctorName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(DateFormat('EEEE, d MMMM').format(appt.date), style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                             decoration: BoxDecoration(
                               color: isPending ? Colors.orange.withValues(alpha: 0.2) : (isCancelled ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2)),
                               borderRadius: BorderRadius.circular(20)
                             ),
                             child: Text(
                               appt.status.toUpperCase(),
                               style: TextStyle(
                                 color: isPending ? Colors.orange : (isCancelled ? Colors.red : Colors.green),
                                 fontSize: 12, fontWeight: FontWeight.bold
                               ),
                             ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(DateFormat('hh:mm a').format(appt.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (isPending)
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                     // Navigate to reschedule
                                     if (doctor != null) {
                                         Navigator.push(context, MaterialPageRoute(builder: (_) => 
                                           BookAppointmentScreen(doctor: doctor, appointmentId: appt.id!.oid)
                                         ));
                                     }
                                  },
                                  child: const Text("Reschedule"),
                                ),
                                TextButton(
                                  onPressed: () => _cancelAppointment(appt.id!),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text("Cancel"),
                                ),
                              ],
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
