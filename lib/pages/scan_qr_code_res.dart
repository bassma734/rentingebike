import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
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
  final String cadenasTopic = "cadenas_topic";
 final String irTopic = "ir_sensor_detection";

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
        if ((qrCode == widget.ebike.name) && (pt == "1" || pt == "2")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  MoneyTimeCounterPage(qrCode: qrCode),
            ),
          );
          // Publish QR code information to MQTT broker
          String ebike = widget.ebike.name ;
          debugPrint ("1st$ebike");
          _publishMessage("1st$ebike");
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
      }},
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
