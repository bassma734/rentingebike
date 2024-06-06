import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:renting_app/services/mqtt_service.dart';
import 'money_time_counter_page.dart';

class ScanQRCodePage extends StatefulWidget {
  const ScanQRCodePage({super.key});

  @override
  ScanQRCodePageState createState() => ScanQRCodePageState();
}

class ScanQRCodePageState extends State<ScanQRCodePage> {
  String qrCode = '';
  final String cadenasTopic = "cadenas_topic";
  MqttService mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    setupMqttClient();
  }

  

  Future<void> setupMqttClient() async {
    await mqttService.connect();
    mqttService.subscribe(cadenasTopic);

  }

  void _publishMessage(String message) {
    mqttService.publishMessage(cadenasTopic, message);
  }

  @override
  Widget build(BuildContext context) {
    return QrCamera(
      qrCodeCallback: (code) {
        setState(() {
          qrCode = code!;
          if (qrCode.startsWith('Ebike')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MoneyTimeCounterPage(qrCode: code),
              ),
            );
            // Publish QR code information to MQTT broker
            debugPrint ("1st$qrCode");
            _publishMessage("1st$qrCode");
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
