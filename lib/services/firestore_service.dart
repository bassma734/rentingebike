import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add or update user information
  Future<void> addUser(String userId, String name, String email) {
    return _db.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'reservation': null,
      'reservation_time': null,
      'status' :null,


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

  Future<DocumentSnapshot> getUserInfo() async {
    User user = _auth.currentUser!;
    return await _db.collection('users').doc(user.uid).get();
  }

  Future<QuerySnapshot> getUserRentals() async {
    User user = _auth.currentUser!;
    return await _db.collection('users').doc(user.uid).collection('rentals').get();
  }


}
