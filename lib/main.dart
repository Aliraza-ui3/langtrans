import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'wrapper.dart';
import 'homepage.dart';
import 'login.dart';
import 'signup.dart';
import 'forgotpassword.dart';
import 'sign_to_text.dart';
import 'text_to_sign_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => Wrapper()),
      GetPage(name: '/home', page: () => HomePage()),
      GetPage(name: '/login', page: () => LoginPage()),
      GetPage(name: '/signup', page: () => SignUpPage()),
      GetPage(name: '/forgot-password', page: () => ForgotPasswordPage()),
      GetPage(name: '/sign_to_text', page: () => SignToTextPage()),
      GetPage(name: '/text_to_sign', page: () => TextToSignPage()),
      GetPage(name: '/profile', page: () => ProfilePage()),
      GetPage(name: '/settings', page: () => SettingsPage()),
    ],
  ));
}
