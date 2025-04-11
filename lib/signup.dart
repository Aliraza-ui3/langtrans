import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  void signUp() async {
    if (isLoading) return; // Prevent double-tap
    setState(() => isLoading = true);

    try {
      String firstName = firstNameController.text.trim();
      String lastName = lastNameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();

      if ([firstName, lastName, email, password, confirmPassword]
          .any((e) => e.isEmpty)) {
        Get.snackbar("Error", "All fields are required",
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() => isLoading = false);
        return;
      }

      if (password != confirmPassword) {
        Get.snackbar("Error", "Passwords do not match",
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() => isLoading = false);
        return;
      }

      // Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore user data
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Account created! Please log in.",
          backgroundColor: Colors.green, colorText: Colors.white);

      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Sign Up Error", e.message ?? "Authentication error",
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : signUp,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
