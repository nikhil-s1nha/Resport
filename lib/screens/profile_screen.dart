import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference userRef =
      FirebaseDatabase.instance.ref('users/${user.uid}');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        fullNameController.text = userData['fullName'] ?? '';
        emailController.text = user.email ?? '';
        phoneController.text = userData['phone'] ?? '';
        addressController.text = userData['address'] ?? '';
        cityController.text = userData['city'] ?? '';
        stateController.text = userData['state'] ?? '';
        zipCodeController.text = userData['zipCode'] ?? '';
        passwordController.text = userData['password'] ?? ''; // Load saved password
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final DatabaseReference userRef =
        FirebaseDatabase.instance.ref('users/${user.uid}');
        await userRef.update({
          'fullName': fullNameController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'zipCode': zipCodeController.text.trim(),
          'password': passwordController.text.trim(), // Save updated password
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!',
            textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to the Home screen
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w500
          ),
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField('Full Name', fullNameController),
            const SizedBox(height: 16),
            buildTextField('Email', emailController, enabled: false),
            const SizedBox(height: 16),
            buildPasswordField('Password (Empty if Google Sign-In)', passwordController),
            const SizedBox(height: 16),
            buildTextField('Phone Number', phoneController),
            const SizedBox(height: 16),
            buildTextField('Address Line', addressController),
            const SizedBox(height: 16),
            buildTextField('City', cityController),
            const SizedBox(height: 16),
            buildTextField('State', stateController),
            const SizedBox(height: 16),
            buildTextField('Zip Code', zipCodeController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F402D), // Olive green
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
        ),
      ),
    );
  }
}