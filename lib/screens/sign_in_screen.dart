import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart'; // Added Google Fonts

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool showPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final DatabaseReference database = FirebaseDatabase.instance.ref("users");

  void signIn() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    // Validate email and password
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter your email",
            style: GoogleFonts.montserrat(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter your password",
            style: GoogleFonts.montserrat(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Authenticate the user with Firebase
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid;

        // Retrieve user data from the database
        final DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref("users").child(uid).get();
        print(FirebaseAuth.instance.currentUser?.uid);

        if (snapshot.exists) {
          final Map<String, dynamic> userData =
          Map<String, dynamic>.from(snapshot.value as Map);

          // Optional: You can display user's name, email, etc., on the home screen
          print("Sign-in successful! Welcome, ${userData['fullName']}");

          // Navigate to the Home Screen
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          throw Exception("User data not found in the database.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${e.toString()}",
            style: GoogleFonts.montserrat(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          "SIGN IN",
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   "SIGN IN",
            //   style: GoogleFonts.montserrat(
            //     textStyle: const TextStyle(
            //       fontSize: 24,
            //       fontWeight: FontWeight.bold,
            //       color: Color(0xFF1F402D),
            //     ),
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 16),

            // Email Input
            SizedBox(
              width: 300,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.montserrat(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password Input
            SizedBox(
              width: 300,
              child: TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: GoogleFonts.montserrat(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Sign In Button
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F402D), // Olive green
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "SIGN IN",
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}