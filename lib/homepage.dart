import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/navigation_drawer.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userFirstName;
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return;
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          userFirstName = doc.exists ? (doc['firstName'] ?? 'User') : 'User';
          userEmail = user.email ?? 'No Email';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userFirstName = 'User';
          userEmail = 'No Email';
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: GoogleFonts.montserrat()),
        elevation: 4,
        backgroundColor: Color(0xFF99CDD8),
      ),
      drawer: NavigationDrawerWidget(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDAEBE3), Color(0xFFFDE8D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 25),
                _buildIntroText(),
                const SizedBox(height: 30),
                _buildOptionCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      children: [
        Hero(
          tag: 'profile-avatar',
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFF657166),
            child: Icon(Icons.person, size: 35, color: Colors.white),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()},',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF657166),
              ),
            ),
            Text(
              userFirstName ?? "User",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF657166),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).moveY(begin: 30);
  }

  Widget _buildIntroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "Easily translate between Sign Language and Text in real-time.\nBridge communication with powerful AI tools.",
        textAlign: TextAlign.center,
        style: GoogleFonts.merriweather(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: Color(0xFF2F3A2F),
          height: 1.6,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).moveY(begin: 20);
  }

  Widget _buildOptionCards() {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          _buildOptionCard(
            icon: Icons.camera_alt,
            title: "Sign-to-Text",
            subtitle: "Use camera for real-time detection",
            route: "/sign_to_text",
            color: Color(0xFFDAEBE3),
            delay: 0,
          ),
          _buildOptionCard(
            icon: Icons.text_fields,
            title: "Text-to-Sign",
            subtitle: "Enter text to translate to sign language",
            route: "/text_to_sign",
            color: Color(0xFFF3C3B2),
            delay: 200,
          ),
          _buildOptionCard(
            icon: Icons.mic,
            title: "Speech-to-Sign",
            subtitle: "Speak to translate to sign language",
            route: "/speech_to_sign",
            color: Color.fromARGB(255, 207, 233, 159),
            delay: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
    int delay = 0,
  }) {
    return Animate(
      effects: [
        FadeEffect(duration: 400.ms, delay: delay.ms),
        MoveEffect(begin: Offset(0, 20), duration: 400.ms, delay: delay.ms),
      ],
      child: InkWell(
        onTap: () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.blueGrey.withOpacity(0.2),
        child: Card(
          color: color,
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.black12,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Color(0xFF657166)),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3A2F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
