import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
//import 'package:qr_mobile_vision/qr_mobile_vision.dart';
import 'package:renting_app/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'money_time_counter_page.dart';
import 'dart:async';

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

  final String userId = "user_id"; // Example user ID, replace with actual user ID

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    setupMqttClient();
    fetchReservations(); // Fetch reservation status when the page initializes
    checkBlockStatus(); // Check if the user is currently blocked
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
          title: const Text('Warning'),
          content: const Text('You have made 5 invalid scans. Please scan a valid eBike QR code.'),
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

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blocked'),
          content: const Text('You have been blocked for 30 days and 5 minutes due to repeated invalid scans.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
    const blockDuration =  Duration(/*days: 30,*/ minutes: 5);
    blockEndTime = DateTime.now().add(blockDuration);
    await FirebaseFirestore.instance.collection('blocked_users').doc(userId).set({
      'blockEndTime': blockEndTime!.toIso8601String(),
    });
    _showBlockDialog();
  }

  void checkBlockStatus() async {
    final doc = await FirebaseFirestore.instance.collection('blocked_users').doc(userId).get();
    if (doc.exists) {
      final blockEndTimeString = doc['blockEndTime'];
      if (blockEndTimeString != null) {
        final blockEnd = DateTime.parse(blockEndTimeString);
        if (DateTime.now().isBefore(blockEnd)) {
          blockEndTime = blockEnd;
          _showBlockDialog();
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
        child: Text("Error: $error"),
      ),
      qrCodeCallback: _handleQRCode,
      notStartedBuilder: (context) => const Center(child: CircularProgressIndicator()),
      offscreenBuilder: (context) => const Center(child: CircularProgressIndicator()),
    ),
    if (isScanning)
      const Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            "Scanning...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
  ],
),
    );
  }
}
