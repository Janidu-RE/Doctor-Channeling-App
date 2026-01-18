import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/Doctor.dart';
import '../doctor/doctor_detail_screen.dart';

class DoctorSearchScreen extends StatefulWidget {
  final String? category;
  const DoctorSearchScreen({super.key, this.category});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ["All", "General", "Cardiology", "Eye", "Skin", "Neurology", "Pediatric"];
  
  String _searchQuery = "";
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    if (widget.category != null && widget.category!.isNotEmpty) {
      _selectedCategory = widget.category!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic is now handled in FirebaseService.getDoctors()

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Doctors"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search doctor",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = "";
                        });
                      },
                    ) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.blue.withOpacity(0.2),
                    checkmarkColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.blue : Colors.transparent)
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategory = cat;
                        } 
                        // Optional: allow deselecting to go back to All? 
                        // For now, enforce one selection or clicking 'All'
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Results List
          Expanded(
            child: FutureBuilder<List<Doctor>>(
              future: FirebaseService.getDoctors(category: _selectedCategory, query: _searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final doctorsData = snapshot.data ?? [];
                if (doctorsData.isEmpty) {
                  return Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      const Text("No doctors found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctorsData.length,
                  itemBuilder: (context, index) {
                    final doc = doctorsData[index];
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doc)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'doctor_search_${doc.id}',
                                child: Container(
                                  width: 70, height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(image: AssetImage(doc.imageUrl), fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Dr. ${doc.username}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(doc.speciality, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        Text(" ${doc.rating}  •  ${doc.experience} yrs exp", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
