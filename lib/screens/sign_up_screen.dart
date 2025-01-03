import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Update with the correct path

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool isEmailEntered = false;
  bool showPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  void _checkFinish() async {
    if (passwordController.text.isEmpty) {
      // Show Snackbar if password is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a password"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      try {
        final String email = emailController.text.trim();
        final String password = passwordController.text;

        await authService.createUser(email, password);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign-up complete!"),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          emailController.clear();
          passwordController.clear();
          isEmailEntered = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SIGN UP",
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
              "Create an Account",
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

            // Conditionally show Password Input
            if (isEmailEntered) ...[
              const SizedBox(height: 16),
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
                        showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
            ],
            const SizedBox(height: 16),

            // Sign/Finish Button
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  if (!isEmailEntered) {
                    // Check if the email is entered
                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter an email"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      isEmailEntered = true;
                    });
                  } else {
                    // Check password before proceeding
                    _checkFinish();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F402D), // Olive green
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  !isEmailEntered ? "Sign Up" : "Finish",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Conditionally hide everything below after "Sign"
            if (!isEmailEntered) ...[
              const SizedBox(height: 24),
              // OR Divider
              Row(
                children: [
                  const Expanded(
                      child: Divider(thickness: 1, indent: 32, endIndent: 8)),
                  Text(
                    "OR",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Expanded(
                      child: Divider(thickness: 1, indent: 8, endIndent: 32)),
                ],
              ),
              const SizedBox(height: 24),

              // Sign In with Email
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle Sign In with Email action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F402D), // Olive green
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign In with Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign Up with Google Button
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add Google sign-up logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB4437), // Google red
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign Up with Apple Button
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add Apple sign-up logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Apple black
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.apple, color: Colors.white),
                  label: const Text(
                    "Continue with Apple",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}