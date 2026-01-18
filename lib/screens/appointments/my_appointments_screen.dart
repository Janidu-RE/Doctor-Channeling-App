import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/services/firebase_service.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/Appointment.dart';
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
    
    try {
      return await FirebaseService.getEnrichedAppointments(user.id!);
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  Future<void> _cancelAppointment(String id) async {
    await FirebaseService.cancelAppointment(id);
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
                                           BookAppointmentScreen(doctor: doctor, appointmentId: appt.id)
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
