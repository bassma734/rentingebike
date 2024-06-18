import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renting_app/pages/main_page.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../pages/user_information_page.dart';
import '../core/constants.dart';

class RentalHistoryPage extends StatefulWidget {
  const RentalHistoryPage({super.key});

  @override
  RentalHistoryPageState createState() => RentalHistoryPageState();
}

class RentalHistoryPageState extends State<RentalHistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _onItemTapped(int index) {
    setState(() {
      MainPageState.selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserInfoPage()),
          (Route<dynamic> route) => false,

        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false,

        );
        break;
      case 2:
        const RentalHistoryPage();
        break;
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    var format = DateFormat('HH:mm'); // Format for time only
    return format.format(timestamp.toDate());
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
        title: const Text('Rental History',style: TextStyle(color: white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(12, 137, 178, 197)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot>(
          future: _firestoreService.getUserRentals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No rental history found'));
            } else {
              var rentals = snapshot.data!.docs;
              return ListView.builder(
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  var rental = rentals[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: primary,
                        child: Icon(Icons.electric_bike, color: Colors.white),
                      ),
                      title: Text('Ebike ID: ${rental['ebikeID'] ?? 'N/A'}'),
                      subtitle: Text(
                        'Time: from ${formatTimestamp(rental['stime'])} to ${formatTimestamp(rental['etime'])}',
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Rental History',
          ),
        ],
        currentIndex: MainPageState.selectedIndex,
        selectedItemColor: primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
