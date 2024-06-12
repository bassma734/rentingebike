import 'package:flutter/material.dart';
import 'package:renting_app/core/constants.dart';
import 'package:renting_app/pages/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'money_time_counter_page.dart';
import 'scan_qr_code_paiement.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  Future<void> _clearReservation() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String ebikeID = ScanQRPCodePageState.code;

        // Update user reservation
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'reservation': null,
          'reservation_time': null,
          'status' : null ,
        });

        // Add rental record to user's document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('rentals').add({
          'ebikeID': ebikeID,
          'stime': MoneyTimeCounterPageState.startTime,
          'etime': MoneyTimeCounterPageState.endTime,
        });

        // Increment the rent count for the e-bike
        await _incrementRentCount(ebikeID);
      }
    } catch (e) {
      debugPrint("Error clearing reservation: $e");
      rethrow;
    }
  }


  Future<void> _incrementRentCount(String ebikeID) async {
    try {
      DocumentReference ebikeRef = FirebaseFirestore.instance.collection('ebikes').doc(ebikeID);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot ebikeSnapshot = await transaction.get(ebikeRef);

        if (!ebikeSnapshot.exists) {
          throw Exception("E-Bike does not exist!");
        }

        var data = ebikeSnapshot.data() as Map<String, dynamic>?;
        int newRentCount = (data?['rent_count'] ?? 0) + 1;
        transaction.update(ebikeRef, {'rent_count': newRentCount});
      });
    } catch (e) {
      debugPrint("Error incrementing rent count: $e");
      rethrow;
    }
  }

  void _navigateHome(BuildContext context) async {
    try {
      await _clearReservation();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error navigating to home: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Your payment has been processed successfully!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Thank you for your payment. You can now continue using our services.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _navigateHome(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: primary,
                    backgroundColor: gray100,
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
}
