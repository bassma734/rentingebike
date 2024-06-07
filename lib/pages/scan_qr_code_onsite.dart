import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:renting_app/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'money_time_counter_page.dart';

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

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    setupMqttClient();
    fetchReservations(); // Fetch reservation status when the page initializes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: QrCamera(
        qrCodeCallback: (code) {
          if (code != null) {
            setState(() {
              qrCode = code;
              if (reservedEbikes.contains(qrCode)) {
                _showReservationDialog();
              } else {
                setupUpdatesListener();
              }
            });
          }
        },
        notStartedBuilder: (context) {
          return const Text("");
        },
        offscreenBuilder: (context) {
          return const Text("QR Code scanner paused");
        },
      ),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
