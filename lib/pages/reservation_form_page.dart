// reservation_form_page.dart
//import 'dart:js_util';

import 'package:flutter/material.dart';
import '../pages/ebike_model.dart';
import 'successful_confirmation.dart';

class ReservationFormPage extends StatefulWidget {
  final Ebike ebike;

  const ReservationFormPage({super.key, required this.ebike});

  @override
  ReservationFormPageState createState() => ReservationFormPageState();
}

class ReservationFormPageState extends State<ReservationFormPage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isReservationTimeSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Form - ${widget.ebike.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bike photo and details
            EbikeDetails(widget.ebike),

            const SizedBox(height: 16),

            // Instruction text
            const Text(
              'Please choose your preferred time for reservation:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showTimePickerDialog(context),
              child: const Text('Select time'),
            ),
            Text('Selected time: ${_selectedTime.format(context)}'),

            // Time slot selector

            // Confirmation button
            ElevatedButton(
              onPressed: _isReservationTimeSelected
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessfulConfirmationPage(ebike: widget.ebike),
                        ),
                      );
                    }
                  : null,
              child: const Text('Confirm Reservation'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePickerDialog(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _isReservationTimeSelected = true;
      });
    }
  }
}

class EbikeDetails extends StatelessWidget {
  final Ebike ebike;

  const EbikeDetails(this.ebike, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          ebike.photo,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ebike.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Charging percentage: ${ebike.chargingPercentage}%'),
            Text('Mileage: ${ebike.mileage} km'),
          ],
        ),
      ],
    );
  }
}