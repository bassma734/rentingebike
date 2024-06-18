// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../pages/ebike_list_page.dart';
import '../pages/map_page.dart';
import '../pages/registration_page.dart';
import '../pages/scan_qr_code_onsite.dart';
import '../pages/successful_confirmation.dart';
import '../pages/rental_history_page.dart';
import '../pages/user_information_page.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/ebike_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool hasReservation = false;
  Map<String, dynamic>? reservationData;
  late Ebike ebikemain;
  static  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _checkReservationStatus();
  }

  Future<void> _checkReservationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          hasReservation = userDoc.data()?['reservation'] != null;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>   const UserInfoPage()),
          (Route<dynamic> route) => false,
        );
        break;
        case 1: MainPage ;
        
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RentalHistoryPage()),
          (Route<dynamic> route) => false,
        );
        break;
    }
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electric_bike, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'RentCycle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final bool shouldLogout = await showConfirmationDialog(
                context: context,
                title: 'Do you want to sign out of the app?',
              ) ?? false;
              if (shouldLogout) {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(12, 137, 178, 197)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text(
              "Please click on the station button for rental reservation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildFeatureCard(
              icon: FontAwesomeIcons.bicycle,
              title: "Make a Reservation",
              subtitle: "Reserve your e-bike at a nearby station",
              onTap: () => goToEbikeListPage(context),
            ),
            const SizedBox(height: 20),
            _buildFeatureCard(
              icon: FontAwesomeIcons.qrcode,
              title: "Scan QR Code",
              subtitle: "Scan the QR code for on-site rental",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanQRCodePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            if (hasReservation)
              _buildFeatureCard(
                icon: FontAwesomeIcons.clipboardCheck,
                title: "Your Reservation",
                subtitle: "View your current reservation status",
                onTap: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                    ebikemain = Ebike(name: userDoc.data()?['reservation'], photo: 'assets/images/Ebike.jpeg');
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessfulConfirmationPage(
                            ebike: ebikemain,
                            selectedTime: userDoc.data()?['reservation_time'],
                            expirationTime: (userDoc.data()?['expiration_time'] as Timestamp).toDate(),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            const SizedBox(height: 20),
            _buildFeatureCard(
              icon: FontAwesomeIcons.locationDot,
              title: "Show Station Location",
              subtitle: "View the location of nearby stations",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
              isPrimary: true,
            ),
          ],
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
        currentIndex: selectedIndex,
        selectedItemColor:primary,
        onTap: _onItemTapped,
      ),
    );
  }

  void goToEbikeListPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EbikeListPage(),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [primary, Color.fromARGB(97, 3, 117, 170)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary ? null : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isPrimary ? Colors.transparent : Colors.black12,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: isPrimary ? Colors.white24 : primary.withOpacity(0.2),
                child: FaIcon(icon, size: 20, color: isPrimary ? Colors.white : primary),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isPrimary ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPrimary)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
