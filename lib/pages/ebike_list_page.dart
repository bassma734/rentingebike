import 'package:flutter/material.dart';
import '../pages/ebike_model.dart';
import '../pages/reservation_form_page.dart';
import '../services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
//import '../pages/successful_confirmation.dart';

class EbikeListPage extends StatefulWidget {
  final bool isReserved;
  const EbikeListPage({super.key, required this.isReserved});

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
    buttonsState();
    setupMqttClient();
    setupUpdatesListener();
  }

  void _initializeButtonStates() {
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
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(248, 242, 251, 253),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 214, 211, 211).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: Image.asset(
            ebike.photo,
            width: 90,
            height: 200,
            fit: BoxFit.fill,
          ),
          title: Text(
            ebike.name,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: enabled ? () => _handleReservationButtonPress(ebike) : null,
            child: const Text('Reserve', style: TextStyle(fontSize: 18)),
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
    ).then((_) {
      setState(() {
        buttonsState();
      });
    });
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
            _reservationButtonStates[0] = true;
          } else if (pt == '2no') {
            _reservationButtonStates[1] = true;
          }
        });
        debugPrint('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      }
    });
  }

  void buttonsState() {
      
    if (ReservationFormPageState.isReserved && widget.isReserved == true) {
      if (ReservationFormPageState.rname == 'Ebike1') {
        _reservationButtonStates[0] = false;
        //_reservationButtonStates[1] = true;
      } else if (ReservationFormPageState.rname == 'Ebike2') {
        _reservationButtonStates[1] = false;
        //_reservationButtonStates[0] = true;
      }
    } else if (widget.isReserved == false && ReservationFormPageState.isReserved) {
      if (ReservationFormPageState.rname == 'Ebike1') {
      
        
        _reservationButtonStates[0] = true;
      } else if (ReservationFormPageState.rname == 'Ebike2') {
        _reservationButtonStates[1] = true;
      }
    }
    else {
      //_initializeButtonStates();
    }
  }


  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
