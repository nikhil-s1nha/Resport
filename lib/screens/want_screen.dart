import 'package:flutter/material.dart';
import 'dart:io'; // Required for local file paths
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';


class WantScreen extends StatelessWidget {
  final String title;
  final String uploadedBy;
  final String imagePath;
  final String description;
  final String transportMethod;
  final String itemKey; // Pass the database key

  const WantScreen({
    Key? key,
    required this.title,
    required this.uploadedBy,
    required this.imagePath,
    required this.description,
    required this.transportMethod,
    required this.itemKey, // Added key parameter
  }) : super(key: key);

  Future<String> fetchFullName(String userId) async {
    try {
      final DatabaseReference userRef =
      FirebaseDatabase.instance.ref("users/$userId");
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return userData['fullName'] ?? userId; // Return fullName if available
      }
    } catch (e) {
      print("Error fetching full name: $e");
    }
    return userId; // Fallback to userId if fullName is not found
  }

  Future<void> markAsUnavailable() async {
    try {
      print("Attempting to mark item as unavailable with key: $itemKey");
      final DatabaseReference globalUploadsRef =
      FirebaseDatabase.instance.ref("globalUploads/$itemKey");

      // Update the 'available' flag
      await globalUploadsRef.update({'available': false});

      print("Item marked as unavailable successfully.");
    } catch (e) {
      print("Error marking as unavailable: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchFullName(uploadedBy),
      builder: (context, snapshot) {
        final displayUploadedBy =
        snapshot.connectionState == ConnectionState.done
            ? snapshot.data ?? uploadedBy
            : "Loading...";

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              color: Colors.white
            ),
            title:  Text(
              "CHECKOUT",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500
              )
              )
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
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
                  )
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
                 Text(
                  "DESCRIPTION:",
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                    fontSize: 19.5,
                    fontWeight: FontWeight.bold,
                  )
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          fontSize: 16,
                        fontWeight: FontWeight.w500
                      )
                  ),
                ),
                const SizedBox(height: 16),

                // Transport method
                 Text(
                  "TRANSPORT METHOD:",
                  style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontSize: 19.5,
                    fontWeight: FontWeight.bold,
                  )
                 )
                ),
                const SizedBox(height: 8),
                Text(
                  transportMethod,
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      )
                  ),
                ),
                const Spacer(),

                // Request button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      print("Request button pressed. Marking item as unavailable...");
                      // Mark the item as unavailable in the database
                      await markAsUnavailable();

                      // Navigate back to home screen with a success message
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(
                            "Success! More details about receiving the product will be emailed!",
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F402D), // Olive green
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:  Text(
                      "REQUEST ITEM",
                      style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )
                  )
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