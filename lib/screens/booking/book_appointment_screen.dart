import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:intl/intl.dart';
import '../../data/models/Doctor.dart';
import '../../data/models/Appointment.dart';
import '../../data/services/mongo_database.dart';
import '../../data/providers/user_provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;
  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<String> _timeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM",
    "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM", "04:00 PM"
  ];

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
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a time slot')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) throw Exception("User not logged in");

      final appointmentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointment = Appointment(
        id: mongo.ObjectId(),
        doctorId: widget.doctor.id!, 
        patientId: user.id!,
        date: appointmentDate,
        status: 'pending',
      );

      await MongoDatabase.appointmentCollection.insert(appointment.toMap());

      if (mounted) {
        showDialog(
          context: context, 
          builder: (ctx) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: const Text("Appointment Booked Successfully!", textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Back to detail
                  Navigator.pop(context); // Back to list/home
                }, 
                child: const Text("OK")
              )
            ],
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    // Basic parser for "HH:mm AM/PM"
    final format = DateFormat.jm(); // 5:08 PM
    final dt = format.parse(timeStr); 
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
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
              children: _timeSlots.map((time) {
                bool isSelected = _selectedTime?.format(context) == time;
                // Note: comparing formatted strings is fragile but okay for simple list
                // Better to compare TimeOfDay objects or indices
                
                return ChoiceChip(
                  label: Text(time),
                  selected: _selectedTime?.format(context) ==  _simpleFormat(time), // hacky check
                  onSelected: (selected) {
                    setState(() {
                         _selectedTime = _stringToTimeOfDay(time);
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(color: _selectedTime == _stringToTimeOfDay(time) ? Colors.white : Colors.black),
                );
              }).toList(),
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
                      child: const Text("Confirm Booking", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  )
          ],
        ),
      ),
    );
  }
  
  TimeOfDay _stringToTimeOfDay(String s) {
     final format = DateFormat.jm(); //"6:00 AM"
     final dt = format.parse(s);
     return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }
  
  // Helper to match the Chip selection logic
  String _simpleFormat(String s) {
      // Just return the string as we select based on strict string equality in UI for now
      // But _selectedTime.format(context) might vary based on locale.
      // Re-formatting the parsed time ensure consistency
      final t = _stringToTimeOfDay(s);
      return t.format(context);
  }
}
