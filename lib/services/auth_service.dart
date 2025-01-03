import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("users");
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Create a user in the database
  Future<void> createUser(String email, String password) async {
    try {
      await _database.push().set({
        'email': email,
        'password': password, // WARNING: Avoid storing plain text passwords in production.
      });
    } catch (e) {
      throw Exception("Error creating user: ${e.toString()}");
    }
  }

  /// Sign in with Google and save the user in the database
  Future<void> signInWithGoogle() async {
    try {
      // Attempt Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the Google Sign-In
        print("Google Sign-In canceled by user.");
        return;
      }

      // Retrieve Google authentication details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a credential using Google authentication tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the credential
      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final String email = user.email ?? "No email";
        final String userId = user.uid;

        // Save user info to Firebase Realtime Database
        await _database.child(userId).set({
          'email': email,
          'password': "GoogleSignIn", // Placeholder password
        });

        print("Google Sign-In successful. User ID: $userId");
      } else {
        print("Google Sign-In failed. No user returned.");
      }
    } catch (e) {
      // Handle exceptions
      print("Error during Google Sign-In: ${e.toString()}");

    }
  }
}