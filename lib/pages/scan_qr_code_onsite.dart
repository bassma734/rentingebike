import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:renting_app/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'money_time_counter_page.dart';
import 'dart:async';
import '../pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanQRCodePage extends StatefulWidget {
  const ScanQRCodePage({super.key});

  @override
  ScanQRCodePageState createState() => ScanQRCodePageState();
}

class ScanQRCodePageState extends State<ScanQRCodePage> {
  String qrCode = '';
  final String cadenasTopic = "cadenas_topic";
  final String irTopic = "ir_sensor_detection";
  late MqttService mqttService;
  Set<String> reservedEbikes = {}; // Set to store reserved eBikes
  bool isScanning = true; // Flag to control scanning
  Timer? scanTimer; // Timer to reset scanning
  int invalidScanCount = 0; // Count of invalid scans
  int invalidScanSeriesCount = 0; // Number of times the invalid scan limit has been reached
  DateTime? blockEndTime; // Time when the user block ends
  String? userId;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    fetchUserId().then((_) {
      checkBlockStatus(); // Check if the user is currently blocked after fetching user ID
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkBlockStatus(); // Check block status every time the page is built
  }

  Future<void> fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      setupMqttClient();
      fetchReservations(); // Fetch reservation status when the page initializes
    }
  }

  @override
  void dispose() {
    mqttService.disconnect();
    scanTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  Future<void> fetchReservations() async {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      Set<String> tempReservations = {};
      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('reservation') && doc['reservation'] != null) {
          tempReservations.add(doc['reservation']);
        }
      }
      setState(() {
        reservedEbikes = tempReservations;
      });
    });
  }

  Future<void> setupMqttClient() async {
    await mqttService.connect();
    mqttService.subscribe(cadenasTopic);
    mqttService.subscribe(irTopic);
  }

  void _publishMessage(String message) {
    mqttService.publishMessage(cadenasTopic, message);
  }

  void setupUpdatesListener() {
    mqttService.getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        if (qrCode.startsWith('Ebike') && (pt == "1" || pt == "2")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MoneyTimeCounterPage(qrCode: qrCode),
            ),
          );
          // Publish QR code information to MQTT broker
          debugPrint("1st$qrCode");
          _publishMessage("1st$qrCode");
        }
      });
      debugPrint('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

  void _showReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reservation Notice'),
          content: const Text('This eBike is reserved. Please scan another eBike.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning', style: TextStyle(fontSize: 22, color: Color.fromARGB(255, 197, 53, 42)), textAlign: TextAlign.center,),
          content: const Text('You have made 5 invalid scans. Please scan a valid eBike QR code.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 197, 53, 42)),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 229, 199, 197),
        );
      },
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blocked', style: TextStyle(color: Color.fromARGB(255, 197, 53, 42), fontSize: 25)),
          content: const Text('You have been blocked for 30 days due to repeated invalid scans.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 197, 53, 42))),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainPage(),
                  ),
                );

                // Navigate back to the main page
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _blockUser() async {
    const blockDuration = Duration(minutes:5); // Adjust duration as needed
    if (userId != null) {
      blockEndTime = DateTime.now().add(blockDuration);
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'blockEndTime': blockEndTime!.toIso8601String(),
      });
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'blockStatus': 'blocked'
      });
      _showBlockDialog();
    }
  }

  void checkBlockStatus() async {
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final blockEndTimeString = doc.data()?['blockEndTime']; // Use null-aware operator
        if (blockEndTimeString != null) {
          final blockEnd = DateTime.parse(blockEndTimeString);
          if (DateTime.now().isBefore(blockEnd)) {
            blockEndTime = blockEnd;
            _showBlockDialog();
          }
        } else {
          // Initialize block status if 'blockEndTime' field is not present
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'blockStatus': 'unblocked'
           }); // Use SetOptions to avoid overwriting the entire document
        }
      }
    }
  }

  void _handleQRCode(String? code) { // Accept nullable String
    if (code != null && isScanning) {
      setState(() {
        if (blockEndTime != null && DateTime.now().isBefore(blockEndTime!)) {
          _showBlockDialog();
          return;
        }

        if (!code.startsWith('Ebike')) {
          invalidScanCount++;
          if (invalidScanCount >= 5) {
            invalidScanSeriesCount++;
            invalidScanCount = 0;
            _showWarningDialog();
            if (invalidScanSeriesCount >= 3) {
              _blockUser();
            }
          } else {
            _showInvalidQRCodeDialog();
          }
        } else {
          qrCode = code;
          if (reservedEbikes.contains(qrCode)) {
            _showReservationDialog();
          } else {
            setupUpdatesListener();
          }
          invalidScanCount = 0; // Reset count on valid scan
          invalidScanSeriesCount = 0; // Reset series count on valid scan
        }

        isScanning = false;
      });

      // Reset the scanning flag after 2 seconds
      scanTimer?.cancel();
      scanTimer = Timer(const Duration(seconds: 2), () {
        setState(() {
          isScanning = true;
        });
      });
    }
  }

  void _showInvalidQRCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid QR Code'),
          content: const Text('Please scan a valid eBike QR code.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          QrCamera(
            onError: (context, error) => Center(
              child: Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            qrCodeCallback: (code) {
              _handleQRCode(code); // Pass code to handleQRCode function
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (qrCode.isNotEmpty)
                  Text(
                    'QR Code: $qrCode',
                    style: const TextStyle(fontSize: 20),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
