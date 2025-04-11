import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../widgets/navigation_drawer.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text("Delete Account"),
        content: Text(
            "Are you sure you want to permanently delete your account? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final uid = _auth.currentUser!.uid;

        // Delete Firestore user data
        await _firestore.collection('users').doc(uid).delete();

        // Delete Firebase auth user
        await _auth.currentUser!.delete();

        // Navigate to login
        Get.offAllNamed('/login');
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to delete account: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      drawer: NavigationDrawerWidget(),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Account",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Manage Email"),
            onTap: () {
              // Handle manage email (optional)
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
            onTap: () async {
              final user = _auth.currentUser;

              if (user != null && user.email != null) {
                try {
                  await _auth.sendPasswordResetEmail(email: user.email!);
                  Get.snackbar(
                    "Password Reset",
                    "A password reset link has been sent to ${user.email}",
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to send password reset email.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Support",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text("FAQ"),
            onTap: () {
              // Show FAQs
            },
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text("Contact Support"),
            onTap: () {
              // Open contact support form or screen
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("About",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text("Terms of Service"),
            onTap: () {
              // Open terms page
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Policy"),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text("Open Source Licenses"),
            onTap: () {
              // Open attributions/licenses
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Danger Zone",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text("Delete Account", style: TextStyle(color: Colors.red)),
            onTap: () => deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
