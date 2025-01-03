import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your password"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final DataSnapshot snapshot = await database.get();
      final Map<dynamic, dynamic>? users = snapshot.value as Map?;

      if (users == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not found"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      bool emailFound = false;
      for (var entry in users.entries) {
        final user = entry.value;
        if (user['email'] == email) {
          emailFound = true;
          if (user['password'] == password) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sign-in successful!"),
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to HomeScreen
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Incorrect password"),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
        }
      }

      if (!emailFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not found"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SIGN IN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F402D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Email Input
            SizedBox(
              width: 300,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Input
            SizedBox(
              width: 300,
              child: TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: "Password",
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
            const SizedBox(height: 16),

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
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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