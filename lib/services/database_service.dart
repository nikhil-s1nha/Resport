import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Write user data to the database
  Future<void> writeUserData(String email, String password) async {
    try {
      final String userId = email.replaceAll('.', '_'); // Firebase keys can't include '.'
      await _databaseRef.child("users/$userId").set({
        'email': email,
        'password': password, // WARNING: Avoid storing plain text passwords in production.
        'createdAt': DateTime.now().toIso8601String(),
      });
      print("User data saved successfully!");
    } catch (error) {
      print("Error saving user data: $error");
    }
  }

  // Read user data from the database
  Future<Map<String, dynamic>?> readUserData(String email) async {
    try {
      final String userId = email.replaceAll('.', '_');
      final DataSnapshot snapshot = await _databaseRef.child("users/$userId").get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        print("No data found for user");
        return null;
      }
    } catch (error) {
      print("Error reading user data: $error");
      return null;
    }
  }
}