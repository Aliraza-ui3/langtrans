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
        await _firestore.collection('users').doc(uid).delete();
        await _auth.currentUser!.delete();
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

  Widget buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color ?? Color(0xFF657166),
        ),
      ),
    );
  }

  Widget buildTile(IconData icon, String title,
      {String? subtitle,
      VoidCallback? onTap,
      Color? iconColor,
      Color? textColor}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Color(0xFF657166)),
        title: Text(
          title,
          style: TextStyle(color: textColor ?? Colors.black87),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDAEBE3),
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Color(0xFF99CDD8),
        elevation: 2,
      ),
      drawer: NavigationDrawerWidget(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          buildSectionTitle("Account"),
          buildTile(Icons.lock, "Change Password", onTap: () async {
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
          }),
          buildSectionTitle("Support"),
          buildTile(Icons.help_outline, "FAQ"),
          buildTile(Icons.support_agent, "Contact Support"),
          buildSectionTitle("About"),
          buildTile(Icons.info_outline, "App Version", subtitle: "1.0.0"),
          buildTile(Icons.description, "Terms of Service"),
          buildTile(Icons.privacy_tip, "Privacy Policy"),
          buildTile(Icons.code, "Open Source Licenses"),
          buildSectionTitle("Danger Zone", color: Colors.red),
          buildTile(Icons.delete_forever, "Delete Account",
              onTap: () => deleteAccount(context),
              iconColor: Colors.red,
              textColor: Colors.red),
        ],
      ),
    );
  }
}
