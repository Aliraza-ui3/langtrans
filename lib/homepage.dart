import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

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

    // Redirect to login if no user found
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

  void _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 4,
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 30),
              _buildOptionCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userFirstName ?? "User",
              style: TextStyle(fontSize: 18),
            ),
            accountEmail: Text(
              userEmail ?? "No Email",
              style: TextStyle(fontSize: 14),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blueGrey),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
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
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, size: 35, color: Colors.white),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()},',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              userFirstName ?? "User",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).moveY(begin: 30);
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
          ).animate().fadeIn(duration: 400.ms).moveY(begin: 20),
          _buildOptionCard(
            icon: Icons.text_fields,
            title: "Text-to-Sign",
            subtitle: "Enter text to translate to sign language",
            route: "/text_to_sign",
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms) // Fixed delay usage
              .moveY(begin: 20),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      onTap: () => Get.toNamed(route), // ✅ FIXED HERE
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.blueGrey.withOpacity(0.2),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blueGrey),
              const SizedBox(height: 12),
              Text(title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
