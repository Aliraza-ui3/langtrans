import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';
import 'login.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Listen for auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator())); // Show loading state
        }

        if (snapshot.hasData && snapshot.data != null) {
          return HomePage(); // User is logged in, show HomePage
        } else {
          return LoginPage(); // User is not logged in, show LoginPage
        }
      },
    );
  }
}
