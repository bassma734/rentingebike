import 'package:flutter/material.dart';
import '../pages/ebike_model.dart';
import '../pages/reservation_form_page.dart';
import '../services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class EbikeListPage extends StatefulWidget {
  const EbikeListPage({super.key});
  
  @override
  EbikeListPageState createState() => EbikeListPageState();
}

class EbikeListPageState extends State<EbikeListPage> {
  MqttService mqttService = MqttService();
  final String irTopic = "ir_sensor_detection";
  final _reservationButtonStates = <bool>[];

  final _ebikesMap = {
    'Ebike1': Ebike(
      name: 'Ebike1',
      photo: 'assets/images/Ebike.jpeg',
    ),
    'Ebike2': Ebike(
      name: 'Ebike2',
      photo: 'assets/images/Ebike.jpeg',
    ),
  };

  @override
  void initState() {
    super.initState();
    _initializeButtonStates();
    setupMqttClient();
    setupUpdatesListener();
  }

  void _initializeButtonStates() {
    // Initialize button states based on the number of ebikes
    _reservationButtonStates.addAll(List<bool>.filled(_ebikesMap.length, true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bike List'),
      ),
      body: _buildEbikeList(),
    );
  }

  Widget _buildEbikeList() {
    return ListView.builder(
      itemCount: _ebikesMap.length,
      itemBuilder: (context, index) {
        final ebike = _ebikesMap.values.elementAt(index);
        return _buildEbikeListTile(ebike, _reservationButtonStates[index]);
      },
    );
  }

  Widget _buildEbikeListTile(Ebike ebike, bool enabled) {
    return GestureDetector(
      onTap: enabled ? () => _handleReservationButtonPress(ebike) : null,
      child: Container(
        padding: const EdgeInsets.all(18), // Increase padding for larger tile size
        margin: const EdgeInsets.symmetric(vertical: 8.0), // Add margin between tiles
        decoration: BoxDecoration(
          color: const Color.fromARGB(248, 242, 251, 253),
          borderRadius: BorderRadius.circular(13), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 214, 211, 211).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(14), // Add padding inside the tile
          leading: Image.asset(
            ebike.photo,
            width: 90, // Increased image width
            height: 200, // Increased image height
            fit: BoxFit.fill,
          ),
          title: Text(
            ebike.name,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20, // Increased font size for title
            ),
          ),
          trailing: ElevatedButton(
            onPressed: enabled ? () => _handleReservationButtonPress(ebike) : null,
            child: const Text('Reserve',style: TextStyle(fontSize: 18),),
          ),
        ),
      ),
    );
  }

  void _handleReservationButtonPress(Ebike ebike) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationFormPage(ebike: ebike),
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttService.connect();
    mqttService.subscribe(irTopic);
  }

  void setupUpdatesListener() {
    mqttService.getMessagesStream()?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c != null && c.isNotEmpty) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        setState(() {
          if (pt == '1') {
            _reservationButtonStates[0] = true;
          } else if (pt == '2') {
            _reservationButtonStates[1] = true;
          } else if (pt == '1no') {
            _reservationButtonStates[0] = false;
          } else if (pt == '2no') {
            _reservationButtonStates[1] = false;
          }
        });
        debugPrint('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      }
    });
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
