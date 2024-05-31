import 'package:flutter/material.dart';
import '../core/constants.dart';
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
  static bool isReserved = false;
  static String rname = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservation Form - ${widget.ebike.name}',
          style: const TextStyle(fontSize: 14),
        ),
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
            Column(
              children: [
                Container(
                  width: 400,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    image: DecorationImage(
                      image: AssetImage(widget.ebike.photo),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Text(
                  widget.ebike.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Please choose your preferred time for reservation:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => _showTimePickerDialog(context),
              style: ElevatedButton.styleFrom(
                side: const BorderSide(width: 1, color: Color.fromARGB(255, 142, 146, 152)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: gray100,
              ),
              child: const Text('Select time', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 25),
            Text('Selected time: ${_selectedTime.format(context)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _isReservationTimeSelected
                  ? () {
                      setState(() {
                        isReserved = true;
                        rname = widget.ebike.name;
                      });
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessfulConfirmationPage(ebike: widget.ebike),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                side: const BorderSide(width: 1, color: Color.fromARGB(255, 8, 8, 8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: gray100,
              ),
              child: const Text('Confirm Reservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
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
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _isReservationTimeSelected = true;
      });
    }
  }
}
