import 'package:flutter/material.dart';
import '../pages/ebike_model.dart';
import '../pages/reservation_form_page.dart';
import '../services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EbikeListPage extends StatefulWidget {
  const EbikeListPage({super.key});

  @override
  EbikeListPageState createState() => EbikeListPageState();
}

class EbikeListPageState extends State<EbikeListPage> {
  MqttService mqttService = MqttService();
  final String irTopic = "ir_sensor_detection";
  final _reservationButtonStates = <bool>[];
  String? userId;
  static bool isReserved = false;

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
    fetchUserIdAndReservation();
  }

  void _initializeButtonStates() {
    _reservationButtonStates.addAll(List<bool>.filled(_ebikesMap.length, true));
  }

  Future<void> fetchUserIdAndReservation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
  FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
  for (var doc in snapshot.docs) {
    if (doc.data().containsKey('reservation') && doc['reservation'] != null) {
      setState(() {
        int index = _ebikesMap.keys.toList().indexOf(doc['reservation']);
        if (index != -1) {
          _reservationButtonStates[index] = false;
          isReserved = true;
        }
      });
    } else {
      setState(() {
        for (int i = 0; i < _reservationButtonStates.length; i++) {
          _reservationButtonStates[i] = true;
        }
        isReserved = false;
      });
    }
  }
});
}
  
    

    // Listen for changes in the reservation status
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('reservation') && doc['reservation'] != null) {
          setState(() {
            int index = _ebikesMap.keys.toList().indexOf(doc['reservation']);
            if (index != -1) {
              _reservationButtonStates[index] = false;
              isReserved = true;
            }
          });
        } else {
          setState(() {
            for (int i = 0; i < _reservationButtonStates.length; i++) {
              _reservationButtonStates[i] = true;
            }
            isReserved = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, Color.fromARGB(80, 3, 168, 244)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Ebike List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(15, 79, 185, 234)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildEbikeList(),
      ),
    );
  }

  Widget _buildEbikeList() {
    return ListView.builder(
      itemCount: _ebikesMap.length,
      itemBuilder: (context, index) {
        String ebikeName = _ebikesMap.keys.elementAt(index);
        Ebike ebike = _ebikesMap[ebikeName]!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 8,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Image.asset(ebike.photo, fit: BoxFit.cover, width: 70),
              title: Text(
                ebike.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              trailing: ElevatedButton(
                onPressed: _reservationButtonStates[index]
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationFormPage(ebike: ebike),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _reservationButtonStates[index] ? primary : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'Reserve',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void setupMqttClient() async {
    await mqttService.connect();
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
}
