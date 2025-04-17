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
  final phoneController = TextEditingController();

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
          phoneController.text = data?['phone'] ?? '';
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
        'phone': phoneController.text.trim(),
        'email': _auth.currentUser?.email ?? '',
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context, true);
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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF99CDD8),
              Color(0xFFDAEBE3),
              Color(0xFFFDE8D3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 10),
                buildTextField("Full Name", nameController),
                buildTextField("Username", usernameController),
                buildTextField("Bio", bioController),
                buildTextField("Location", locationController),
                buildTextField("Phone Number", phoneController),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Icon(Icons.save, color: Colors.white),
                  label: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Color(0xFF657166),
                  ),
                  onPressed: isLoading ? null : saveProfile,
                ),
                SizedBox(height: 235),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType:
            label.contains("Phone") ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF657166)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.85),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF99CDD8), width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
