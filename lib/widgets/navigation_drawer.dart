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
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
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
                  onTap: () {
                    Get.offAllNamed('/home');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    Get.toNamed('/profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Get.toNamed('/settings');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
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
}
