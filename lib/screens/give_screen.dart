import 'package:flutter/material.dart';
import 'dart:io';
import '../services/image_service.dart';
import 'package:image_picker/image_picker.dart';



class GiveScreen extends StatefulWidget {
  const GiveScreen({super.key});

  @override
  State<GiveScreen> createState() => GiveScreenState();
}

class GiveScreenState extends State<GiveScreen> {
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

  File? image;
  final ImageService imageService = ImageService();
  Future<void> pickImage(ImageSource source) async{
    final File? _image = await imageService.pickImage(source);
    if (_image != null) {
      setState(() {
        image = _image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GIVE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Question
            const Text(
              "Choose a sport to upload equipment of:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Add spacing
            // Dropdown
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
              value: selectedSport, // Selected value
              hint: const Text("Select a sport"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSport = newValue; // Update selected sport
                });
              },
              items: sportsList.map((sport) {
                return DropdownMenuItem<String>(
                  value: sport,
                  child: Text(sport),
                );
              }).toList(),
            ),
            if (selectedSport != null)
              Column(
                children: [
                  const SizedBox(height: 24), // Add spacing
                  SizedBox(
                      width: 160,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            File? _image = await imageService.pickImage(ImageSource.gallery);
                            if (_image != null) {
                              setState(() {
                                image = _image;
                              });
                              print("Image picked successfully: ${_image.path}");
                            } else {
                              print("No image selected");
                            }
                          } catch (e) {
                            print("Error during image selection: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F402D),
                          // Olive green color
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Upload Photo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                  ),
                ]
              ),
            if (image != null)
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Selected Image:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Image.file(
                    image!,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                ]
              )
          ],
        ),
      ),
    );
  }
}