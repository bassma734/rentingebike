import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renting_app/services/mqtt_service.dart';
import 'ebike_model.dart';
import '../core/constants.dart';

class SuccessfulConfirmationPage extends StatefulWidget {
  final Ebike ebike;
  final String selectedTime;
  final DateTime expirationTime;

  const SuccessfulConfirmationPage( {
    super.key,
    required this.ebike,
    required this.selectedTime,
    required this.expirationTime,
  });

  @override
  SuccessfulConfirmationPageState createState() =>
      SuccessfulConfirmationPageState();
}

class SuccessfulConfirmationPageState extends State<SuccessfulConfirmationPage> {
  final String reservationTopic = "reservation";
  MqttService mqttService = MqttService();
  String? userId;

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
  void _publishMessage(String message) {
    mqttService.publishMessage(reservationTopic, message);
  }

  Future<void> _fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _confirmReservation(user.uid);  // Confirm reservation once userId is fetched
    }
  }

  Future<void> _confirmReservation(String userId) async {
    try {
      // Update Firestore with the reservation details
      await FirebaseFirestore.instance.collection('users').add({
        
        'ebikeId': widget.ebike.name,
        'reservationTime': widget.selectedTime,
        'expirationTime': widget.expirationTime,
      });

      // Publish the reservation details to the MQTT broker

    _publishMessage("confirmed");
      
    } catch (e) {
      debugPrint('Failed to confirm reservation: $e');
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Reservation Confirmed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You have successfully reserved ${widget.ebike.name} at ${widget.selectedTime}.',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please scan the QR code within 15 minutes of your selected time.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








