import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'sign_up_screen.dart'; // Import the Sign Up Screen
import 'want_screen.dart'; // Import the Want Screen for navigation

class GetScreen extends StatefulWidget {
  const GetScreen({super.key});

  @override
  State<GetScreen> createState() => _GetScreenState();
}

class _GetScreenState extends State<GetScreen> {
  String? selectedSport;
  final List<String> sportsList = [
    "Soccer",
    "Basketball",
    "Tennis",
    "Baseball",
    "Hockey",
    "Golf",
    "Other",
  ];

  List<Map<String, dynamic>> uploads = [];
  bool isLoading = false;

  Future<void> fetchUploads(String sport) async {
    setState(() {
      isLoading = true;
      uploads = [];
    });

    try {
      print("Fetching uploads for sport: $sport...");
      final DatabaseReference database =
      FirebaseDatabase.instance.ref("globalUploads");
      final snapshot = await database.get();

      if (snapshot.exists) {
        print("Uploads found in database.");
        final Map<String, dynamic> globalUploadsData =
        Map<String, dynamic>.from(snapshot.value as Map);

        // Filter uploads by sport and check if available
        for (var uploadEntry in globalUploadsData.entries) {
          final upload = uploadEntry.value as Map;
          if (upload['sport'] == sport && (upload['available'] ?? true)) {
            uploads.add({
              'title': upload['title'],
              'imageUrl': upload['imagePath'], // Firebase Storage URL
              'description': upload['description'],
              'transportMethod': upload['transportMethod'],
              'uploadedBy': upload['uploadedBy'],
              'key': uploadEntry.key, // Keep track of the database key
            });
          }
        }
      } else {
        print("No uploads found in database.");
      }
    } catch (e) {
      print("Error fetching uploads: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching uploads: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.broken_image, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GET",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for selecting a sport
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              value: selectedSport,
              hint: const Text("Select a sport"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSport = newValue;
                  if (newValue != null) {
                    fetchUploads(newValue);
                  }
                });
              },
              items: sportsList.map((sport) {
                return DropdownMenuItem<String>(
                  value: sport,
                  child: Text(sport),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Loading indicator or upload list
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (uploads.isEmpty)
              const Center(
                child: Text(
                  "No uploads found for this sport.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 8.0, // Space between columns
                    mainAxisSpacing: 8.0, // Space between rows
                    childAspectRatio: 1.1, // Adjust this to control the card height
                  ),
                  itemCount: uploads.length,
                  itemBuilder: (context, index) {
                    final upload = uploads[index];
                    return GestureDetector(
                      onTap: () async {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          // Redirect to sign-up screen if not signed in
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(fromRedirect: true), // Pass the flag
                            ),
                          );
                          return;
                        }

                        print("Navigating to WantScreen with key: ${upload['key']}");
                        // Navigate to WantScreen and wait for it to complete
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WantScreen(
                              title: upload['title'],
                              uploadedBy: upload['uploadedBy'],
                              imagePath: upload['imageUrl'],
                              description: upload['description'],
                              transportMethod: upload['transportMethod'],
                              itemKey: upload['key'], // Pass the database key
                            ),
                          ),
                        );

                        // Refresh the list after returning from WantScreen
                        if (selectedSport != null) {
                          print("Refreshing uploads for sport: $selectedSport...");
                          fetchUploads(selectedSport!);
                        }
                      },
                      child: Card(
                        elevation: 4.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: buildImage(upload['imageUrl'])),
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                upload['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}