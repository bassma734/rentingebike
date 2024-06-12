import 'package:flutter/material.dart';
import 'package:renting_app/core/dialogs.dart';
import 'package:renting_app/pages/main_page.dart';
import 'package:renting_app/pages/scan_qr_code_res.dart';
import 'package:renting_app/services/mqtt_service.dart';
import '../core/constants.dart';
import 'ebike_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuccessfulConfirmationPage extends StatefulWidget {
  final Ebike ebike;
  final String selectedTime;
  final DateTime expirationTime;

  const SuccessfulConfirmationPage({
    required this.ebike,
    required this.selectedTime,
    required this.expirationTime,
    super.key,
  });

  @override
  SuccessfulConfirmationPageState createState() => SuccessfulConfirmationPageState();
}

class SuccessfulConfirmationPageState extends State<SuccessfulConfirmationPage> {
  final String reservationTopic = "reservation";
  late MqttService mqttService;
  late String userId;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    setupMqttClient();
    _fetchUserIdAndConfirmReservation();
  }

  Future<void> setupMqttClient() async {
    await mqttService.connect();
    mqttService.subscribe(reservationTopic);
  }

  void _publishMessage(String message) {
    mqttService.publishMessage(reservationTopic, message);
  }

  Future<void> _fetchUserIdAndConfirmReservation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
       
        _confirmReservation();
        _scheduleReservationCancellation();
      }
    }
  }

  Future<void> _confirmReservation() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'reservation': widget.ebike.name,
        'status': 'confirmed',
        'reservation_time': widget.selectedTime,
        'expiration_time': widget.expirationTime,
      });
      _publishMessage("confirmed");
    } catch (e) {
      debugPrint("Error confirming reservation: $e");
    }
  }

  void _scheduleReservationCancellation() {
    final DateTime now = DateTime.now();
    final Duration durationUntilExpiration = widget.expirationTime.difference(now);

    if (durationUntilExpiration.isNegative) {
      _cancelReservation();
    } 
  }

  Future<void> _cancelReservation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'reservation': null,
        'reservation_time': null,
        'expiration_time': null,
        'status': 'cancelled',
      });
      _publishMessage("cancelled");
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/check_icon.png',
                              width: 80,
                              height: 50,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Reservation Confirmed!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Color.fromARGB(255, 181, 181, 181)),
                        const SizedBox(height: 10),
                        Text(
                          'Bike ID: ${widget.ebike.name}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Reservation Time: ${widget.selectedTime}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Color.fromARGB(255, 181, 181, 181)),
                        const SizedBox(height: 10),
                        const Text(
                          'Enjoy your ride! If your total exceeds 5 DT, you will receive a 2.5 DT refund.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Note: Please arrive on time. If you are late, you have a 15-minute grace period. After that, your reservation will be canceled.',
                          style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 201, 47, 36), fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Scan the QR code when you get there.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 94, 149, 179),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanQRCodeResPage(ebike: widget.ebike),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () async {
                    final bool cancel = await showConfirmationDialog(
                      context: context,
                      title: 'Do you want to cancel your reservation?',
                    ) ?? false;
                    if (cancel) {
                      await _cancelReservation();
                      _publishMessage("cancelled");
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Reservation'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(210, 255, 82, 82),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: primary,
                    backgroundColor: gray100,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 20,
                    shadowColor: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
