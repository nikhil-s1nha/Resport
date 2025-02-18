import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart'; // Added Google Fonts
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user profile using Firebase UID
      final DatabaseReference database = FirebaseDatabase.instance.ref();
      final snapshot = await database.child('users/${user.uid}').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          name = data['fullName'] ?? 'User'; // Use 'fullName' key from the database
          isAuthenticated = true;
        });
      } else {
        setState(() {
          name = 'User'; // Fallback if no data found
          isAuthenticated = true;
        });
      }
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      isAuthenticated = false;
      name = null;
    });
  }

  void _launchURL() async {
    final Uri url = Uri.parse("https://gofund.me/1e7a3bf2");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HOME",
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
        actions: isAuthenticated
            ? [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle_sharp,
              color: Colors.white,
              size: 34,
            ),
            onSelected: (value) {
              if (value == "Profile") {
                Navigator.pushNamed(context, '/profile'); // Navigate to profile screen
              } else if (value == "My Items") {
                Navigator.pushNamed(context, '/items'); // Navigate to My Items screen
              } else if (value == "Logout") {
                logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "Profile",
                child: Text(
                  "PROFILE",
                  style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
              PopupMenuItem(
                value: "My Items",
                child: Text(
                  "MY ITEMS",
                  style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
              PopupMenuItem(
                value: "Logout",
                child: Text(
                  "LOGOUT",
                  style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ]
            : null,
      ),
      body: Column(
        children: [
          // Top banner
          Container(
            width: double.infinity,
            color: const Color(0xFFE6E6E6), // Light gray banner background
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              isAuthenticated
                  ? "Welcome to Resport, ${name}!"
                  : "Welcome to Resport!",
              style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 145, // Adjust width to fit the longest text
                    height: 65, // Keep height consistent
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/give');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2a573d), // Olive green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded edges
                        ),
                      ),
                      child: Text(
                        "GIVE",
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 145,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/get');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2a573d), // Olive green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "GET",
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isAuthenticated) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 145,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign-up');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a573d), // Olive green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "SIGN UP",
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 22, // Slightly smaller as per your original request
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 64),
                  GestureDetector(
                    onTap: _launchURL,
                    child: Container(
                      width: 275,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFF50784d),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Donate to Resport!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}