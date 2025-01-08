import 'package:flutter/material.dart';
import 'dart:io'; // Required for File
import 'package:firebase_database/firebase_database.dart';

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
      final DatabaseReference database = FirebaseDatabase.instance.ref("globalUploads");
      final snapshot = await database.get();

      if (snapshot.exists) {
        final Map<String, dynamic> globalUploadsData =
        Map<String, dynamic>.from(snapshot.value as Map);

        // Filter uploads by sport
        for (var upload in globalUploadsData.values) {
          if (upload is Map && upload['sport'] == sport) {
            uploads.add({
              'title': upload['title'],
              'imageUrl': upload['imagePath'], // Assuming local file path
            });
          }
        }
      }
    } catch (e) {
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
                    return Card(
                      elevation: 4.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.file(
                              File(upload['imageUrl']), // Local file path
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
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