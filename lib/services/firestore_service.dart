import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add or update user information
  Future<void> addUser(String userId, String name, String email) {
    return _db.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'reservation': null,
      'reservation_time': null,
      'reservation_status' :null,
      'rental':null,
      'rental_time_date' :null,


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


}
