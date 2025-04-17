import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NavigationDrawerWidget extends StatefulWidget {
  @override
  _NavigationDrawerWidgetState createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
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
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
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
          userEmail = user?.email ?? 'No Email';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFFDAEBE3), // soft background
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF99CDD8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    accountName: Text(
                      userFirstName ?? "User",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF657166),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail: Text(
                      userEmail ?? "No Email",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF657166),
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Color(0xFFF3C3B2),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                _buildListTile(Icons.home, 'Home', '/home'),
                _buildListTile(Icons.person, 'Profile', '/profile'),
                _buildListTile(Icons.settings, 'Settings', '/settings'),
                Divider(
                    thickness: 1, color: Color(0xFF657166).withOpacity(0.2)),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await _auth.signOut();
                    Get.offAllNamed('/login');
                  },
                ),
              ],
            ),
    );
  }

  ListTile _buildListTile(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF657166)),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF657166),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Get.toNamed(route);
      },
    );
  }
}
