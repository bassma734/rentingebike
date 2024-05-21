// reservation_form_page.dart
//import 'dart:js_util';
//import 'package:flutter/services.dart';

import '../core/constants.dart';

import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
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
        title: Text('Reservation Form - ${widget.ebike.name}', style: const TextStyle(fontSize:14 ),),
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
            Column(
              children: [
                Container(
                  width: 400,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width:1),
                    image: DecorationImage(
                      image: AssetImage(widget.ebike.photo),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
                const SizedBox(width :25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height:28),

                    Text(
                      widget.ebike.name,
                      style: const TextStyle(fontSize:26, fontWeight: FontWeight.w400),
                    ),

                  ],
                ),
              
            
            const SizedBox(height : 16),

            // Instruction text
            const Text(
              'Please choose your preferred time for reservation:',
              style: TextStyle(fontSize: 16 ),
              textAlign:TextAlign.center
            ),
            const SizedBox(height : 25),
            ElevatedButton(
              onPressed: () => _showTimePickerDialog(context),

              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 1, color: Color.fromARGB(255, 142, 146, 152)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // border radius
                  backgroundColor: gray100,
                ),
              child: const Text('Select time' ,style: TextStyle(fontSize: 22 ,fontWeight: FontWeight.w500)),



            ),
            const SizedBox(height:25),
            Text('Selected time: ${_selectedTime.format(context)}',style: const TextStyle(fontSize: 20 ,fontWeight: FontWeight.w500)),
            const SizedBox(height:25),


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
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 1, color: Color.fromARGB(255, 8, 8, 8)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // border radius
                  backgroundColor: gray100,
                ),    
              child: const Text('Confirm Reservation',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500 )),
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
          width : 100,
          height : 100,
          fit: BoxFit.cover,
        ),
        const SizedBox(width : 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ebike.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
           
          ],
        ),
      ],
    );
  }
}