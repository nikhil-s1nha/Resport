import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GiveScreen extends StatefulWidget {
  const GiveScreen({super.key});

  @override
  State<GiveScreen> createState() => GiveScreenState();
}

class GiveScreenState extends State<GiveScreen> {
  String? selectedSport;
  String? transportMethod;
  final List<String> sportsList = [
    "Soccer",
    "Basketball",
    "Tennis",
    "Baseball",
    "Hockey",
    "Golf",
    "Other",
  ];

  final List<String> transportMethods = [
    "Self-Deliver",
    "Home Pickup",
    "Third-Party Service (UPS, USPS, etc)",
  ];

  File? image;
  bool isPhotoUploaded = false;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> handleUpload() async {
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

    try {
      final pickedImage =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          image = File(pickedImage.path);
          isPhotoUploaded = true;
        });
        print("Image picked successfully: ${image!.path}");
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error during image selection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting image: $e")),
      );
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef =
      FirebaseStorage.instance.ref().child('uploads/$fileName');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }

  Future<void> uploadDataToDatabase() async {
    if (image == null ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        transportMethod == null ||
        selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(
              "Please complete all fields before uploading.",
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              )
            )
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(
              "You must be signed in to upload.",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  )
              )
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final imageUrl = await uploadImageToStorage(image!);

      // Prepare references
      final DatabaseReference userUploadsRef =
      FirebaseDatabase.instance.ref("users/${user.uid}/uploads");
      final DatabaseReference globalUploadsRef =
      FirebaseDatabase.instance.ref("globalUploads");

      // Prepare data
      final newUpload = {
        'sport': selectedSport,
        'imagePath': imageUrl, // Use the download URL from Firebase Storage
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'transportMethod': transportMethod,
        'uploadedBy': user.uid,
        'uploadedAt': DateTime.now().toIso8601String(),
        'available': true, // Set the listing as available by default
      };

      // Upload data
      await userUploadsRef.push().set(newUpload);
      await globalUploadsRef.push().set(newUpload);

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(
              "Upload successful!",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  )
              ),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Reset state
      setState(() {
        image = null;
        titleController.clear();
        descriptionController.clear();
        selectedSport = null;
        transportMethod = null;
        isPhotoUploaded = false;
      });

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error uploading data: $e"),
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
          color: Colors.white,
        ),
        title: Text(
          "GIVE",
            style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                )
            )
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Text(
              "CHOOSE YOUR ITEM'S CATEGORY:",
                style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )
                )
            ),
            const SizedBox(height: 8),
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
              hint: Text(
                  "                    SELECT A SPORT",
                  style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87
                      )
                  )
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSport = newValue;
                });
              },
              items: sportsList.map((sport) {
                return DropdownMenuItem<String>(
                  value: sport,
                  child: Text(
                    sport,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w500
                      )
                    )
                  ),
                );
              }).toList(),
            ),
            if (selectedSport != null && !isPhotoUploaded)
              Column(
                children: [
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F402D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "UPLOAD PHOTO",
                          style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )
                          )
                      ),
                    ),
                  ),
                ],
              ),
            if (image != null)
              Column(
                children: [
                  const SizedBox(height: 16),
                   Text(
                    "SELECTED IMAGE:",
                    style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.file(
                    image!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: GoogleFonts.montserrat(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description (Model, Wear, Age)",
                      labelStyle: GoogleFonts.montserrat(),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Text(
                        "SELECT TRANSPORT METHOD:",
                        style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        value: transportMethod,
                        hint:  Text("                       Transport Method",
                            style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w500
                                )
                            )
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            transportMethod = newValue;
                          });
                        },
                        items: transportMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: uploadDataToDatabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F402D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "UPLOAD",
                          style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )
                          )
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}