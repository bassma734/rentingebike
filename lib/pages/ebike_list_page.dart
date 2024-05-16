import 'package:flutter/material.dart';
import '../pages/ebike_model.dart';
import '../pages/reservation_form_page.dart';
import '../services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
//import 'main_page.dart' ;



class EbikeListPage extends StatefulWidget {
  const EbikeListPage({super.key  });
  @override
  EbikeListPageState createState() => EbikeListPageState();
}

class EbikeListPageState extends State<EbikeListPage> {
  MqttService mqttService = MqttService();
  final String irTopic = "ir_sensor_detection";
  final _reservationButtonStates = List<bool>.filled(2, false);



  final _ebikesMap = {
    'Ebike1': Ebike(
      name: 'Ebike1',
      photo: 'assets/images/ebike1.jpg',
      
    ),
    'Ebike2': Ebike(
      name: 'Ebike2',
      photo: 'assets/images/ebike1.jpg',
      
    ),
  };

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
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
      child: ListTile(
        leading: Image.asset(
          ebike.photo,
          width:70,
          height: 70,
          fit: BoxFit.cover,
        ),
        title: Text(
          ebike.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
         
        ),
        trailing: ElevatedButton(
          onPressed: enabled ? () => _handleReservationButtonPress(ebike) : null,
          child: const Text('Reserve'),
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

  void setupUpdatesListener( ) {
    mqttService.getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
          final recMess = c![0].payload as MqttPublishMessage;
          final pt =MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          setState(() {
          if (pt== '1') {
            _reservationButtonStates[0] = true;
          } else if (pt == '2'){
            _reservationButtonStates[1] = true;
          } else if (pt == '1no') {
            _reservationButtonStates[0] = false;
          } else if (pt == '2no') {
            _reservationButtonStates[1] = false ;
          }});
          debugPrint('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

}


