import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:renting_app/change_notifiers/registration_controller.dart';
import 'firestore_service.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final FirestoreService _firestoreService = FirestoreService();

  static User? get user => _auth.currentUser;

  static Stream<User?> get userStream => _auth.userChanges();

  static bool get isEmailVerified => user?.emailVerified ?? false;

  static Future<void> register({
  required String fullName,
  required String email,
  required String password,
  required String phoneNumber,
}) async {
  try {
    // Create user with email and password
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the created user
    User? user = credential.user;
    if (user != null) {
      // Send email verification
      await user.sendEmailVerification();

      // Update display name
      await user.updateDisplayName(fullName);

      
      // Add user to Firestore
      await _firestoreService.addUser(user.uid, fullName, email , phoneNumber);
    }
  } catch (e) {
    rethrow; // Rethrow any exceptions for handling elsewhere
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

    // Once signed in, get the UserCredential
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    User? user = userCredential.user;
    if (user != null) {
      // Check if the user exists in Firestore
      bool userExists = await _firestoreService.checkUserExists(user.uid);

      if (!userExists) {
        // Add new user to Firestore
        await _firestoreService.addUser(
            user.uid, user.displayName ?? 'Unknown', user.email ?? 'No email',user.phoneNumber);
      }
    }

    return userCredential;
  }

  static Future<void> resetPassword({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
