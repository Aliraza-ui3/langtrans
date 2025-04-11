import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final usernameController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController(); // ✅ Phone controller

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          final data = doc.data();
          nameController.text = data?['fullName'] ?? '';
          bioController.text = data?['bio'] ?? '';
          usernameController.text = data?['username'] ?? '';
          locationController.text = data?['location'] ?? '';
          phoneController.text = data?['phone'] ?? ''; // ✅ Load phone number
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'username': usernameController.text.trim(),
        'location': locationController.text.trim(),
        'phone': phoneController.text.trim(), // ✅ Save phone number
        'email': _auth.currentUser?.email ?? '',
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context, true); // ✅ Trigger refresh in profile page
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField("Full Name", nameController),
            buildTextField("Username", usernameController),
            buildTextField("Bio", bioController),
            buildTextField("Location", locationController),
            buildTextField(
                "Phone Number", phoneController), // ✅ Add phone field
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : Icon(Icons.save),
              label: Text("Save"),
              onPressed: isLoading ? null : saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType:
            label.contains("Phone") ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
