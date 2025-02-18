import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:resportcode/screens/sign_in_screen.dart';
import '../services/auth_service.dart'; // Update with the correct path
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  final bool fromRedirect; // Flag to check if redirected from another screen

  const SignUpScreen({super.key, this.fromRedirect = false}); // Default to false

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool isEmailEntered = false;
  bool showPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Show a snackbar if redirected
    if (widget.fromRedirect) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(
                "Please sign in to use this feature!",
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500
                  )
                ),
                textAlign: TextAlign.center,
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void checkFinish() async {
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(
            "Please enter a password!",
            style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500
                )
            ),
          textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      try {
        final String email = emailController.text.trim();
        final String password = passwordController.text;
        final String name = nameController.text.trim();

        // Call Firebase Auth to create a user
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Save user info to Realtime Database
        final String uid = credential.user!.uid;
        await FirebaseDatabase.instance.ref('users/$uid').set({
          'fullName': name,
          'email': email,
          'password': password, // Save the password (not recommended in production)
        });

        print(FirebaseAuth.instance.currentUser?.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Sign-up complete!",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500
            )
          ),
          textAlign: TextAlign.center
        ),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          emailController.clear();
          passwordController.clear();
          nameController.clear();
          isEmailEntered = false;
        });

        // Navigate to HomeScreen
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Handle email already in use
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "The email address is already in use. Please sign in instead.",
                style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500
                    )
                ),
                textAlign: TextAlign.center,
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to Sign-In screen
          Navigator.pushNamed(context, '/sign-in');
        } else {
          // Handle other Firebase Auth errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.message}",
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500
                      )
                  ),
                textAlign: TextAlign.center,
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}",
                style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500
                    )
                ),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void handleGoogleSignIn() async {
    try {
      await authService.signInWithGoogle();

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text("Google sign-in successful!",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500
                  )
              ),
          textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to HomeScreen
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500
                  )
              ),
          textAlign: TextAlign.center,
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
          color: Colors.white, // Make it white
        ),
        title:  Text(
          "SIGN UP",
          style: GoogleFonts.montserrat(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          )
      )
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                "CREATE AN ACCOUNT",
                style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F402D),
                )
              ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Name Input
              if (isEmailEntered) ...[
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: GoogleFonts.montserrat(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email Input
              SizedBox(
                width: 300,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w500
                      )
                    ),
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
                      labelStyle: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w500
                      )
                    ),
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
                           SnackBar(
                            content: Text("Please enter an email!",
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              textAlign: TextAlign.center
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        isEmailEntered = true;
                      });
                    } else {
                      // Check password and name before proceeding
                      checkFinish();
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
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )
                    )
                  ),
                ),
              ),

              // Conditionally hide everything below after "Sign"
              if (!isEmailEntered) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                        child: Divider(thickness: 1, indent: 32, endIndent: 8)),
                    Text(
                      "OR",
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      )
                      )
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F402D), // Olive green
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Sign In with Email",
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Up with Google Button
                SizedBox(
                  width: 250,
                  child: ElevatedButton.icon(
                    onPressed: handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB4437), // Google red
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    label:  Text(
                      "Continue with Google",
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )
                      )
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}