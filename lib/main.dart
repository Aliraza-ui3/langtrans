import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'wrapper.dart';
import 'homepage.dart';
import 'login.dart';
import 'signup.dart';
import 'forgotpassword.dart';
import 'sign_to_text.dart';
import 'text_to_sign_page.dart';
import 'speech_to_sign.dart';
import 'profile_page.dart';
import 'settings_page.dart';

// Platform channel for hand tracking
const MethodChannel _handTrackingChannel =
    MethodChannel('com.yourdomain.mediapipe/hands');

Future<void> startHandTracking() async {
  try {
    final result = await _handTrackingChannel.invokeMethod('startHandTracking');
    print("Hand Tracking Started: $result");
  } on PlatformException catch (e) {
    print("Error starting hand tracking: ${e.message}");
  }
}

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
      GetPage(name: '/sign_to_text', page: () => SignToText()),
      GetPage(name: '/text_to_sign', page: () => TextToSignPage()),
      GetPage(name: '/speech_to_sign', page: () => SpeechToSignPage()),
      GetPage(name: '/profile', page: () => ProfilePage()),
      GetPage(name: '/settings', page: () => SettingsPage()),
    ],
  ));
}
