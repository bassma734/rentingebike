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
  final List<bool> _reservationButtonStates = [];
  String? userId;
  final Map<String, Ebike> _ebikesMap = {};

  @override
  void initState() {
    super.initState();
    setupMqttClient();
    setupUpdatesListener();
    fetchUserIdAndData();
  }

  Future<void> fetchUserIdAndData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
    // Fetch eBikes and reservation states from Firestore
    await fetchEbikes();
    await fetchReservationStates();
  }

  Future<void> fetchEbikes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('ebikes').get();
    setState(() {
      for (var doc in snapshot.docs) {
        String id = doc['id'];
        _ebikesMap[id] = Ebike(
          name: id,
          photo: 'assets/images/Ebike.jpeg', // Or update this based on the data from Firestore
        );
      }
      _initializeButtonStates();
    });
  }

  void _initializeButtonStates() {
    _reservationButtonStates.clear();
    _reservationButtonStates.addAll(List<bool>.filled(_ebikesMap.length, true));
  }

  Future<void> fetchReservationStates() async {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      setState(() {
        for (int i = 0; i < _reservationButtonStates.length; i++) {
          _reservationButtonStates[i] = true; // Reset button states to true initially
        }
      });

      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('reservation') && doc['reservation'] != null) {
          String reservedEbike = doc['reservation'];
          int index = _ebikesMap.keys.toList().indexOf(reservedEbike);
          if (index != -1) {
            setState(() {
              _reservationButtonStates[index] = false; // Disable the button for the reserved eBike
            });
          }
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
}
