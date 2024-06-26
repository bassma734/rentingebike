import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renting_app/pages/pay.dart';
import 'package:renting_app/pages/successful_confirmation.dart';
import 'package:renting_app/services/mqtt_service.dart';
import '../core/constants.dart';
import '../pages/ebike_model.dart';
import '../services/payment_service.dart';

class ReservationFormPage extends StatefulWidget {
  final Ebike ebike;

  const ReservationFormPage({super.key, required this.ebike});

  @override
  ReservationFormPageState createState() => ReservationFormPageState();
}

class ReservationFormPageState extends State<ReservationFormPage> {
  static TimeOfDay selectedTime = TimeOfDay.now();
  bool _isReservationTimeSelected = false;
  late String userId;
  final String reservationTopic = "reservation";
  late MqttService mqttService;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    setupMqttClient();
    _fetchUserId();
  }

  Future<void> setupMqttClient() async {
    await mqttService.connect();
    mqttService.subscribe(reservationTopic);
  }

  Future<void> _fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
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
                  'Selected time: ${selectedTime.format(context)}',
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
                    ? () => _showConfirmationDialog(context)
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
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

Future<void> _showTimePickerDialog(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: selectedTime,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: primary,
            onPrimary: Colors.white,
            onSurface: Colors.black,
            onSurfaceVariant: primary,
            primaryContainer: primary,
            surfaceVariant: gray100,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primary,
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != selectedTime) {
    final now = TimeOfDay.now();
    final nowDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      now.hour,
      now.minute,
    );

    var selectedDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      picked.hour,
      picked.minute,
    );

    // Adjust for selected time after midnight
    if (selectedDateTime.isBefore(nowDateTime)) {
      selectedDateTime = selectedDateTime.add(const Duration(days: 1));
    }

    final differenceInMinutes = selectedDateTime.difference(nowDateTime).inMinutes;

    if (differenceInMinutes < 15 || differenceInMinutes > 120) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time between 15 minutes and 2 hours from now.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      selectedTime = picked;
      _isReservationTimeSelected = true;
    });
  }
}

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Reservation'),
          content: const Text('A 5 DT payment is required to confirm your reservation. Tap OK to continue.\n\n'
                              'Please note: You have a 15-minute grace period after your selected reservation time.'
                              'If you do not scan the QR code within this time, your reservation will be automatically canceled.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog

                try {
                  final paymentUrl = await _paymentService.createPayment(
                    5.0, // Assuming the payment amount is 5 DT
                    'Bassma', 
                    'Zeineb', 
                    'bessa@gmail.com', 
                    '+21622334455',
                  );
                // Calculate expiration time
                final DateTime now = DateTime.now();
                final DateTime selectedDateTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                final DateTime expirationTime = selectedDateTime.add(const Duration(minutes: 2));
                  if (paymentUrl != null) {
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          paymentUrl: paymentUrl,
                          nextPage: SuccessfulConfirmationPage(
                            ebike: widget.ebike,
                            selectedTime: selectedTime.format(context),
                            expirationTime: expirationTime,
                          ),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Payment creation failed: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
