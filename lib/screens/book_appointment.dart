// book_appointment.dart

import 'package:flutter/material.dart';

class BookAppointmentPage extends StatelessWidget {
  // Dummy list of doctors
  final List<String> dermatologists = ['Dr. Smith', 'Dr. Johnson', 'Dr. Lee'];
  final List<String> pas = ['PA Clark', 'PA Taylor', 'PA Davis'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Dermatologists:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...dermatologists.map((doctor) {
              return ListTile(
                title: Text(doctor),
                trailing: ElevatedButton(
                  onPressed: () {
                    _bookAppointment(context, doctor);
                  },
                  child: const Text('Book'),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            const Text(
              'Physician Assistants (PA):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...pas.map((pa) {
              return ListTile(
                title: Text(pa),
                trailing: ElevatedButton(
                  onPressed: () {
                    _bookAppointment(context, pa);
                  },
                  child: const Text('Book'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _bookAppointment(BuildContext context, String doctorName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Book Appointment'),
          content: Text('You have selected $doctorName.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Appointment with $doctorName booked!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
