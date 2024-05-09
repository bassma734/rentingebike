import 'package:flutter/material.dart';



class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  ReservationPageState createState() => ReservationPageState();
}

class ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add bike image and details here
            Image.asset('assets/images/ebike1.jpg'),
            const SizedBox(height: 16.0),
            const Text('This is a cool e-bike with a top speed of 20 mph and a range of 30 miles.'),

            // Add reservation form here
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Please choose your preferred time for reservation:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Select time'),
                  ),
                  Text('Selected time: ${_selectedTime.format(context)}'),
                  ElevatedButton(
                    onPressed: (){
                      if (_formKey.currentState!.validate()) {
                        // Handle reservation here
                        
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
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
      });
    }
  }
}