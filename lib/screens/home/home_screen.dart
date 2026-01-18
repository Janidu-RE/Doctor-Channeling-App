import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/services/mongo_database.dart';
import '../../data/models/Doctor.dart';
import '../auth/login_screen.dart';
import 'doctor_search_screen.dart';
import '../appointments/my_appointments_screen.dart';
import '../history/patient_history_screen.dart';
import '../doctor/doctor_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const MyAppointmentsScreen(),
    const PatientHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hello,", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      Text(
                        user?.username ?? "User",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.blue),
                      onPressed: () {
                         Provider.of<UserProvider>(context, listen: false).logout();
                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/hospital_banner_1768762970105.png"),
                    fit: BoxFit.cover,
                    opacity: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Medical Checkup", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("Check your health condition regularly to minimize disease.", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorSearchScreen()));
                      },
                      child: const Text("Check Now"),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Search (Visual)
              TextField(
                decoration: InputDecoration(
                  hintText: "Search doctor or symptoms...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                 onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorSearchScreen()));
                 },
                 readOnly: true,
              ),
              const SizedBox(height: 25),

              // Categories
              const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem(context, Icons.favorite, "Cardiology", Colors.red),
                    _buildCategoryItem(context, Icons.local_hospital, "General", Colors.blue),
                    _buildCategoryItem(context, Icons.visibility, "Eye", Colors.purple),
                    _buildCategoryItem(context, Icons.face, "Skin", Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Top Doctors
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Top Doctors", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorSearchScreen())),
                    child: const Text("See All"),
                  )
                ],
              ),
              const SizedBox(height: 10),
              
              // Doctor List Builder
              FutureBuilder(
                future: MongoDatabase.doctorCollection.find({'role': 'doctor'}).toList(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || (snapshot.data as List).isEmpty) return const Text("No doctors found.");
                  
                  var docs = snapshot.data as List;
                  return Column(
                    children: docs.take(3).map((d) {
                      final doc = Doctor.fromMap(d);
                      return Card(
                         margin: const EdgeInsets.only(bottom: 15),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                         child: ListTile(
                           contentPadding: const EdgeInsets.all(10),
                           leading: Hero(
                             tag: 'doctor_${doc.id}',
                             child: Container(
                               width: 60, height: 60,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(10),
                                 image: DecorationImage(image: AssetImage(doc.imageUrl), fit: BoxFit.cover),
                               ),
                             ),
                           ),
                           title: Text("Dr. ${doc.username}", style: const TextStyle(fontWeight: FontWeight.bold)),
                           subtitle: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(doc.speciality, style: TextStyle(color: Colors.blue[300])),
                               Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text(" ${doc.rating}")])
                             ],
                           ),
                           trailing: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                               backgroundColor: Colors.blue[50],
                               foregroundColor: Colors.blue
                             ),
                             onPressed: () {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doc)));
                             },
                             child: const Text("View"),
                           ),
                         ),
                      );
                    }).toList(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorSearchScreen(category: label)));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }
}
