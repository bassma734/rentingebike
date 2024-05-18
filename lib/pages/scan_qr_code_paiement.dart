import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:renting_app/services/mqtt_service.dart';
import '../pages/paiement_page.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ScanQRPCodePage extends StatefulWidget {
  final String name;

  const ScanQRPCodePage({super.key, required this.name});

  @override
  ScanQRPCodePageState createState() => ScanQRPCodePageState();
}

class ScanQRPCodePageState extends State<ScanQRPCodePage> {
  String qrCode = '';
  final String servoTopic = "servo_control_topic";
  final String irTopic = "ir_sensor_detection";
  late MqttService mqttService;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    setupMqttClient();
  }

  Future<void> setupMqttClient() async {
    await mqttService.connect();
    mqttService.subscribe(irTopic);
  }

  void _publishMessage(String message) {
    mqttService.publishMessage(servoTopic, message);
  }

  void setupUpdatesListener() {
    mqttService.getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        if ((qrCode == widget.name) && (pt == "1" || pt == "2")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PaiementPage(),
            ),
          );
          // Publish QR code information to MQTT broker
          String ebike = widget.name ;
          debugPrint ("2nd$ebike");
          _publishMessage("2nd$ebike");
        }
      });
      debugPrint('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return QrCamera(
      qrCodeCallback: (code) {
        if (code != null) {
          setState(() {
            qrCode = code;
            setupUpdatesListener();
          });
        }
      },
      notStartedBuilder: (context) {
        return const Text("");
      },
      offscreenBuilder: (context) {
        return const Text("QR Code scanner paused");
      },
    );
  }

  /*@override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }*/
}
