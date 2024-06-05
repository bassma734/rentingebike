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
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, Color.fromARGB(80, 3, 168, 244)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ' ${widget.ebike.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(15, 79, 185, 234)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
<<<<<<< HEAD
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
=======
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          //child: SingleChildScrollView(
>>>>>>> e75efee65d1650a7e7ebdd929d43dd8acbca1a41
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(widget.ebike.photo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                /*Center(
                  child: Text(
                    widget.ebike.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),*/
                /*const SizedBox(height: 16),*/
                const Center(
                  child: Text(
                    'Please choose your preferred time for reservation:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTimePickerDialog(context),
                    icon: const Icon(Icons.access_time),
                    label: const Text(
                      'Select Time',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: Colors.black26,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Selected time: ${_selectedTime.format(context)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Confirm Reservation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: _isReservationTimeSelected ? primary : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 20,
                    shadowColor: Colors.black26,
                  ),
                ),
<<<<<<< HEAD
                //const SizedBox(height: 50),

=======
                const SizedBox(height: 25),
>>>>>>> e75efee65d1650a7e7ebdd929d43dd8acbca1a41
              ],
            ),
          ),
        ),
<<<<<<< HEAD
    );
=======
      );
    //);
>>>>>>> e75efee65d1650a7e7ebdd929d43dd8acbca1a41
  }

  Future<void> _showTimePickerDialog(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
              onSurfaceVariant: primary,
              primaryContainer: primary,
              surfaceVariant: gray100,         
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primary, // button text color
              ),
            ),
          ),
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
