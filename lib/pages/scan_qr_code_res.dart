import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:renting_app/pages/ebike_model.dart';
import 'package:renting_app/services/mqtt_service.dart';
import 'money_time_counter_page.dart';

class ScanQRCodeResPage extends StatefulWidget {
  final Ebike ebike;
  const ScanQRCodeResPage({super.key,required this.ebike});

  @override
  ScanQRCodeResPageState createState() => ScanQRCodeResPageState();
}

class ScanQRCodeResPageState extends State<ScanQRCodeResPage> {
  String qrCode = '';
  final String servoTopic = "servo_control_topic";
  MqttService mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    setupMqttClient();
  }

  

  Future<void> setupMqttClient() async {
    await mqttService.connect();
    mqttService.subscribe(servoTopic);

  }

  void _publishMessage(String message) {
    mqttService.publishMessage(servoTopic, message);
  }

  @override
  Widget build(BuildContext context) {
    return QrCamera(
      qrCodeCallback: (code) {
        setState(() {
          qrCode = code!;
          if (qrCode == widget.ebike.name ) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MoneyTimeCounterPage(qrCode: code),
              ),
            );
            // Publish QR code information to MQTT broker
            _publishMessage("1st");
          }
        });
      },
      notStartedBuilder: (context) {
        return const Text("");
      },
      offscreenBuilder: (context) {
        return const Text("QR Code scanner paused");
      },
    );
  }

    @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
