import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();

  void resetPassword() async {
    try {
      String email = emailController.text.trim(); // Trim to remove spaces

      if (email.isEmpty) {
        Get.snackbar("Error", "Please enter your email.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Check if email format is valid
      if (!GetUtils.isEmail(email)) {
        Get.snackbar("Error", "Invalid email format.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Firebase reset password method
      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar("Success", "Password reset email sent!",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offNamed('/login'); // Navigate back to Login page
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter your email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
