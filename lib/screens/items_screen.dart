import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'individual_item_screen.dart'; // Import the new screen

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<Map<String, dynamic>> userItems = [];
  bool isLoading = false;
  int currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    fetchUserItems();
  }

  Future<void> fetchUserItems() async {
    setState(() {
      isLoading = true;
      userItems = [];
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final DatabaseReference database =
      FirebaseDatabase.instance.ref("users/${user.uid}/uploads");
      final snapshot = await database.get();

      if (snapshot.exists) {
        final Map<String, dynamic> uploadsData =
        Map<String, dynamic>.from(snapshot.value as Map);

        for (var uploadEntry in uploadsData.entries) {
          final upload = uploadEntry.value as Map;
          userItems.add({
            'title': upload['title'],
            'imageUrl': upload['imagePath'],
            'description': upload['description'],
            'transportMethod': upload['transportMethod'],
            'key': uploadEntry.key,
          });
        }
      }
    } catch (e) {
      print("Error fetching user uploads: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching items: $e"),
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
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.broken_image, size: 50),
    );
  }

  List<Map<String, dynamic>> getCurrentPageItems() {
    if (userItems.isEmpty) return [];

    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    if (startIndex >= userItems.length) startIndex = userItems.length - 1;
    if (startIndex < 0) startIndex = 0;
    if (endIndex > userItems.length) endIndex = userItems.length;

    return userItems.sublist(startIndex, endIndex);
  }

  void goToPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (userItems.length / itemsPerPage).ceil();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Ensure refresh when going back
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          title: Text(
            "MY ITEMS",
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF1F402D),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (userItems.isEmpty)
                Center(
                  child: Text(
                    "No items found.",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      ...getCurrentPageItems().map((item) {
                        return GestureDetector(
                          onTap: () async {
                            bool? shouldRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IndividualItemScreen(
                                  itemKey: item['key'],
                                  title: item['title'],
                                  description: item['description'],
                                  imageUrl: item['imageUrl'],
                                  transportMethod: item['transportMethod'],
                                ),
                              ),
                            );

                            if (shouldRefresh == true) {
                              fetchUserItems(); // Refresh data when returning
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  buildImage(item['imageUrl']),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['description'],
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              if (totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: currentPage > 1
                          ? () => goToPage(currentPage - 1)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    for (int i = 1; i <= totalPages; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextButton(
                          onPressed: () => goToPage(i),
                          style: TextButton.styleFrom(
                            backgroundColor: currentPage == i
                                ? const Color(0xFF1F402D)
                                : Colors.transparent,
                            foregroundColor:
                            currentPage == i ? Colors.white : Colors.black,
                          ),
                          child: Text(
                            "$i",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: currentPage < totalPages
                          ? () => goToPage(currentPage + 1)
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}