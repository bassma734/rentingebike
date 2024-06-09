import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:renting_app/services/mqtt_service.dart';
import 'end_location.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ScanQRCodePage extends StatefulWidget {
  final String name;
  final double amount;


  const ScanQRCodePage({super.key, required this.name,  required this.amount});

  @override
  ScanQRPCodePageState createState() => ScanQRPCodePageState();
}

class ScanQRPCodePageState extends State<ScanQRCodePage> {
  String qrCode = '';
  final String cadenasTopic = "cadenas_topic";
  final String irTopic = "ir_sensor_detection";
  late MqttService mqttService;
  static late String code ;

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
    mqttService.publishMessage(cadenasTopic, message);
  }

  void setupUpdatesListener() {
    mqttService.getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        if ((qrCode == widget.name) && (pt == "1" || pt == "2")) {
          code =qrCode ;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  EndLocation(amount: widget.amount ),
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

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}







