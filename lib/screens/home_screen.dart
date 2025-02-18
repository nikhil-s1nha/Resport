import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "HOME",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w500
            )),
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
              } else if (value == "Logout") {
                logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "Profile",
                child: Text("Profile"),
              ),
              const PopupMenuItem(
                value: "Logout",
                child: Text("Logout"),
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
                  : "Welcome to Resport!" ,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/give');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a573d), // Olive green
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 25),
                    ),
                    child: const Text(
                      "GIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/get');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a573d), // Olive green
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 25),
                    ),
                    child: const Text(
                      "GET",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (!isAuthenticated) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/sign-up');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2a573d), // Olive green
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 25),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 64),
                  Container(
                      width: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: const Color(0xFF50784d),
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: const Text(
                          'ALL FUNDS DIRECTED TO ALAMEDA COUNTY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                      )
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