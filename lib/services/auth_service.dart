//import 'package:flutter/material.dart';
import 'package:renting_app/change_notifiers/registration_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'firestore_service.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  //static final FirestoreService _firestoreService = FirestoreService();

  static User? get user => _auth.currentUser;

  static Stream<User?> get userStream => _auth.userChanges();

  static bool get isEmailVerified => user?.emailVerified ?? false;

  static Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((credential) {
        credential.user?.sendEmailVerification();
        credential.user?.updateDisplayName(fullName);
      });

      /*// Add user to Firestore
      await _firestoreService.addUser(user!.uid, fullName, email);
      // Verify user is added
      bool userExists = await _firestoreService.checkUserExists(user!.uid);
      if (userExists) {
        debugPrint("User successfully added to Firestore.");
      } else {
        debugPrint("Failed to add user to Firestore.");
      }*/


    } catch (e) {
      rethrow;
    }
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw const NoGoogleAccountChosenException();
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  static Future<void> resetPassword({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
