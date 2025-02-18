import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class IndividualItemScreen extends StatefulWidget {
  final String itemKey;
  final String title;
  final String description;
  final String imageUrl;
  final String transportMethod;

  const IndividualItemScreen({
    super.key,
    required this.itemKey,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.transportMethod,
  });

  @override
  State<IndividualItemScreen> createState() => _IndividualItemScreenState();
}

class _IndividualItemScreenState extends State<IndividualItemScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedTransportMethod;

  final List<String> transportMethods = [
    "Home Pickup",
    "Third-Party Transfer",
    "Self-Deliver",
  ];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    selectedTransportMethod = widget.transportMethod;
  }

  Future<void> updateItem() async {
    setState(() {
      isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DatabaseReference itemRef =
    FirebaseDatabase.instance.ref("users/${user.uid}/uploads/${widget.itemKey}");

    try {
      await itemRef.update({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'transportMethod': selectedTransportMethod,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item updated successfully!"),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Indicate refresh is needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating item: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> deleteItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DatabaseReference itemRef =
    FirebaseDatabase.instance.ref("users/${user.uid}/uploads/${widget.itemKey}");

    try {
      await itemRef.remove();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item deleted successfully!"),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Indicate refresh is needed after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting item: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, false); // Do not refresh if no changes were made
          },
        ),
        title: Text(
          "EDIT ITEM",
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1F402D),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: deleteItem,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrl,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: selectedTransportMethod,
              hint: const Text("Transport Method"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTransportMethod = newValue;
                });
              },
              items: transportMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: isSaving ? null : updateItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F402D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Save",
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
  }
}