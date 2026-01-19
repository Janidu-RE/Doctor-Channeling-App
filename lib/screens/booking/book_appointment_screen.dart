import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/firebase_service.dart';
import '../../data/providers/user_provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/Doctor.dart';
import '../../data/models/Appointment.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;
  final String? appointmentId; // If provided, we are rescheduling
  
  const BookAppointmentScreen({super.key, required this.doctor, this.appointmentId});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedSlotIndex = -1; // -1 means no selection
  bool _isLoading = false;

  final List<String> _timeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM",
    "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM", "04:00 PM"
  ];
  
  @override
  void initState() {
    super.initState();
    // If rescheduling, we could technically pre-fill the old date/time 
    // but starting fresh is often clearer for "picking a NEW time"
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlotIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a time slot')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) {
        throw Exception("You must be logged in to book an appointment.");
      }

    // Firestore is cleaner, no explicit connect check needed here usually
    
    if (widget.doctor.id == null) {
       throw Exception("Doctor ID is invalid.");
    }
    
    if (user.id == null) {
       throw Exception("User ID is invalid. Please relogin.");
    }

      // Convert selected slot string to TimeOfDay
      final timeStr = _timeSlots[_selectedSlotIndex];
      final time = _parseTime(timeStr);

      final appointmentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        time.hour,
        time.minute,
      );

      if (widget.appointmentId != null) {
         // RESCHEDULE MODE: Update existing
         await FirebaseService.updateAppointment(widget.appointmentId!, {
           'date': appointmentDate.toIso8601String(),
           'status': 'pending'
         });
         print("Rescheduled to $appointmentDate");
      } else {
         // NEW BOOKING MODE
          final appointment = Appointment(
            id: null, // Let Firestore generate ID
            doctorId: widget.doctor.id!, 
            patientId: user.id!,
            date: appointmentDate,
            status: 'pending',
          );
    
          await FirebaseService.bookAppointment(appointment);
      }


      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: Text(widget.appointmentId != null ? "Rescheduled Successfully!" : "Appointment Booked Successfully!", textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close BookAppointmentScreen
                  
                  // If it's a new booking, we might want to pop again to go back to Home/Search
                  // But if it's rescheduling, we want to stay in MyAppointmentsScreen to see the change
                  if (widget.appointmentId == null) {
                      Navigator.pop(context); // Back to list/search
                  }
                }, 
                child: const Text("OK")
              )
            ],
          )
        );
      }
    } catch (e, stack) {
      print("Booking Error: $e\n$stack");
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Booking Failed"),
            content: Text(e.toString()),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    // Manually parse HH:mm AM/PM to avoid locale/format issues
    try {
      final parts = timeStr.split(' '); // ["09:00", "AM"]
      final timeParts = parts[0].split(':'); // ["09", "00"]
      
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      String period = parts[1]; // AM or PM

      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Error parsing time: $timeStr -> $e");
      // Fallback
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointmentId != null ? "Reschedule Appointment" : "Book Appointment"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Summary
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(widget.doctor.imageUrl),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Dr. ${widget.doctor.username}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(widget.doctor.speciality, style: const TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            const Divider(height: 40),

            // Date Selection
            const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('EEEE, d MMMM y').format(_selectedDate), style: const TextStyle(fontSize: 16)),
                  IconButton(onPressed: () => _selectDate(context), icon: const Icon(Icons.calendar_month, color: Colors.blue))
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Time Slots
            const Text("Select Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: List.generate(_timeSlots.length, (index) {
                final time = _timeSlots[index];
                final isSelected = _selectedSlotIndex == index;
                
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                         _selectedSlotIndex = selected ? index : -1;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }),
            ),
            
            const SizedBox(height: 40),
            
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _bookAppointment,
                      child: Text(widget.appointmentId != null ? "Confirm Reschedule" : "Confirm Booking", style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  )
          ],
        ),
      ),
    );
  }
  

  
  // Helper to match the Chip selection logic

}
