import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("users");
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Create a user in the database
  Future<void> createUser(String email, String password, String fullName) async {
    try {
      // Authenticate the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid; // Get authenticated user's UID

        // Save user data under their UID in the database
        await _database.child("users").child(uid).set({
          'email': email,
          'fullName': fullName, // Store full name
          'password': password, // WARNING: Avoid storing plain text passwords in production!
        });

        // Optionally, delete temporary sign-up data if stored
        await _database.child("signUp").child(uid).remove();
      }
    } catch (e) {
      throw Exception("Error creating user: ${e.toString()}");
    }
  }

  /// Sign in with Google and save the user in the database
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In canceled by user.");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final String email = user.email ?? "No email";
        final String userId = user.uid;
        final String displayName = user.displayName ?? "No name";
        final String profilePicture =
            user.photoURL ?? "https://example.com/default-profile.png";

        // Save user info to Firebase Realtime Database
        await _database.child(userId).set({
          'email': email,
          'name': displayName,
          'profilePicture': profilePicture,
          'signInMethod': "GoogleSignIn",
        });

        print("Google Sign-In successful. User ID: $userId");
      } else {
        print("Google Sign-In failed. No user returned.");
      }
    } catch (e) {
      print("Error during Google Sign-In: ${e.toString()}");
    }
  }

  /// Retrieve user profile from the database
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final DataSnapshot snapshot = await _database.child(uid).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        print("User profile not found.");
        return null;
      }
    } catch (e) {
      throw Exception("Error retrieving user profile: ${e.toString()}");
    }
  }
}