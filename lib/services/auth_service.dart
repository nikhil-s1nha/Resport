import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("users");

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
}