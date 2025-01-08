import 'package:flutter/material.dart';
import 'dart:io'; // Required for local file paths
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WantScreen extends StatelessWidget {
  final String title;
  final String uploadedBy;
  final String imagePath;
  final String description;
  final String transportMethod;

  const WantScreen({
    Key? key,
    required this.title,
    required this.uploadedBy,
    required this.imagePath,
    required this.description,
    required this.transportMethod,
  }) : super(key: key);

  Future<String> fetchUserName(String userId) async {
    try {
      final DatabaseReference usersRef = FirebaseDatabase.instance.ref("users/$userId");
      final userSnapshot = await usersRef.get();

      if (userSnapshot.exists) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        return userData['fullName'] ?? userId; // Return fullName if available, else userId
      }
    } catch (e) {
      // Handle potential errors
      print("Error fetching username: $e");
    }
    return userId; // Default to userId if name not found
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchUserName(uploadedBy),
      builder: (context, snapshot) {
        final displayUploadedBy = snapshot.data ?? uploadedBy; // Show fetched username or default ID
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Want",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1F402D), // Olive green color
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and uploader info
                Text(
                  "$title uploaded by $displayUploadedBy",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Display image
                Center(
                  child: imagePath.startsWith('/Users') // Check if it's a local file
                      ? Image.file(
                    File(imagePath),
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
                  )
                      : Image.network(
                    imagePath,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  "Description:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Transport method
                const Text(
                  "Transport Method:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  transportMethod,
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),

                // Request button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to home screen with a success message
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Success! More details about receiving the product will be emailed!",
                            textAlign: TextAlign.center,
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F402D), // Olive green
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Request Item",
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
      },
    );
  }
}