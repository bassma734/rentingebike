/*import 'package:flutter/material.dart';
//import 'package:mqtt_client/mqtt_client.dart';
import '../pages/ebike_model.dart';
import '../pages/reservation_form_page.dart';
//import '../services/mqtt_service.dart';

class EbikeListPage extends StatefulWidget {
  const EbikeListPage({super.key});

  @override
  EbikeListPageState createState() => EbikeListPageState();
}

class EbikeListPageState extends State<EbikeListPage> {
  final _ebikesMap = {
    'Ebike 1': Ebike(
      name: 'Ebike 1',
      photo: 'assets/images/ebike1.jpg',
      chargingPercentage: 80,
      mileage: 70,
    ),
    'Ebike 2': Ebike(
      name: 'Ebike 2',
      photo: 'assets/images/ebike1.jpg',
      chargingPercentage: 90,
      mileage: 100,
    ),
  };

  //late MqttService _mqttService;
  final _reservationButtonEnabled = ValueNotifier(false);

  @override
  /*void initState() {
    super.initState();
    _mqttService = MqttService();
    _mqttService.client.connectionStatus!.listen((status) {
      if (status.state == MqttConnectionState.connected) {
        _mqttService.subscribe('ir_sensor_detection');
        _mqttService.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess = c[0].payload;
          final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          if (message == 'no') {
            _reservationButtonEnabled.value = false;
          } else {
            _reservationButtonEnabled.value = true;
          }
        });
      } else {
        _reservationButtonEnabled.value = false;
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bike List'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _reservationButtonEnabled,
        builder: (context, enabled, child) {
          return ListView.builder(
            itemCount: _ebikesMap.length,
            itemBuilder: (context, index) {
              final ebike = _ebikesMap.values.elementAt(index);
              return _buildEbikeListTile(ebike, enabled);
            },
          );
        },
      ),
    );
  }

  Widget _buildEbikeListTile(Ebike ebike, bool enabled) {
    return GestureDetector(
      onTap: enabled ? () => _handleReservationButtonPress(ebike) : null,
      child: ListTile(
        leading: Image.asset(
          ebike.photo,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          ebike.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Charging percentage: ${ebike.chargingPercentage}%'),
            Text('Mileage: ${ebike.mileage} km'),
          ],
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
}*/



// ebike_list_page.dart
import 'package:flutter/material.dart';
import '../pages/ebike_model.dart';
import '../pages/reservation_form_page.dart';
//import '../services/mqtt_service.dart' ;

class EbikeListPage extends StatefulWidget {
  const EbikeListPage({super.key});

  @override
  EbikeListPageState createState() => EbikeListPageState();
}

class EbikeListPageState extends State<EbikeListPage> {
  final List<Ebike> ebikesList = [
    Ebike(
      name: 'Ebike1',
      photo: 'assets/images/ebike1.jpg',
      chargingPercentage: 80,
      mileage: 70,
    ),
    Ebike(
      name: 'Ebike2',
      photo: 'assets/images/ebike1.jpg',
      chargingPercentage: 90,
      mileage: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bike List'),
      ),
      body: ListView.builder(
        itemCount: ebikesList.length,
        itemBuilder: (context, index) {
          final ebike = ebikesList[index];
          return _buildEbikeListTile(ebike);
        },
      ),
    );
  }

  Widget _buildEbikeListTile(Ebike ebike) {
    return GestureDetector(
      
      child: ListTile(
        leading: Image.asset(
          ebike.photo,
          width : 50,
          height : 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          ebike.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Charging percentage: ${ebike.chargingPercentage}%'),
            Text('Mileage: ${ebike.mileage} km'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _handleReservationButtonPress(ebike);
          },
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
}