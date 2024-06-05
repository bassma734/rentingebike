import 'package:flutter/material.dart';
import 'package:renting_app/pages/main_page.dart';
import 'package:renting_app/pages/scan_qr_code_res.dart';
import '../pages/ebike_model.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuccessfulConfirmationPage extends StatefulWidget {
  final  Ebike ebike;

  const SuccessfulConfirmationPage({required this.ebike, super.key});

  @override
  SuccessfulConfirmationPageState createState() => SuccessfulConfirmationPageState();
}

class SuccessfulConfirmationPageState extends State<SuccessfulConfirmationPage> {

  static Ebike ebikemain = Ebike(name: 'ebike', photo: 'assets/images/Ebike.jpeg');
  //static bool isReserved = false;

  @override
  Widget build(BuildContext context) {
    ebikemain = widget.ebike;
    /*setState(() {
       isReserved = true;
    });*/
   

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(15, 79, 185, 234)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/check_icon.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 20),
                           Text(
                          'Your ${widget.ebike.name} reservation has been confirmed successfully.',
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Scan the QR code when you get there.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 119, 188, 225),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanQRCodeResPage(ebike: widget.ebike),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    /*setState(() {
                       isReserved = false;
                    });*/
                               

                    final bool cancel = await showConfirmationDialog(
                          context: context,
                          title: 'Do you want to cancel your reservation?',
                        ) ??
                        false;
                    if (cancel) {
                      await cancelReservation();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Reservation'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(210, 255, 82, 82),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: primary, backgroundColor: gray100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> cancelReservation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'reservation': null,
        'reservation_time': null,
      });
    }
  }
}
