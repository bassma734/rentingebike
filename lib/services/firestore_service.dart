import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Add or update user information
  Future<void> addUser( String name, String email) {
    return _db.collection('users').add({
      'name': name,
      'email': email,
   // ignore: body_might_complete_normally_catch_error
   }).catchError((error) {
        debugPrint("Error adding user: $error");
      });
    }
  
  // Check if a user document exists
  Future<bool> checkUserExists(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }
  

  // Get user information
  Future<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // Add rental history
  Future<void> addRental(String uid, Map<String, dynamic> rentalData) {
    return _db.collection('users').doc(uid).collection('rentals').add(rentalData);
  }

  // Add reservation history
  Future<void> addReservation(String uid, Map<String, dynamic> reservationData) {
    return _db.collection('users').doc(uid).collection('reservations').add(reservationData);
  }

  // Add payment history
  Future<void> addPayment(String uid, Map<String, dynamic> paymentData) {
    return _db.collection('users').doc(uid).collection('payments').add(paymentData);
  }

  // Get user's rental history
  Stream<QuerySnapshot> getUserRentals(String uid) {
    return _db.collection('users').doc(uid).collection('rentals').snapshots();
  }

  // Get user's reservation history
  Stream<QuerySnapshot> getUserReservations(String uid) {
    return _db.collection('users').doc(uid).collection('reservations').snapshots();
  }

  // Get user's payment history
  Stream<QuerySnapshot> getUserPayments(String uid) {
    return _db.collection('users').doc(uid).collection('payments').snapshots();
  }
}
