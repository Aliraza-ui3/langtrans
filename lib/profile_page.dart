import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/navigation_drawer.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setState(() {
          isLoading = false;
          userData = {};
        });
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          userData = {};
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        userData = {};
        isLoading = false;
      });
    }
  }

  Widget _buildInfoTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value?.isNotEmpty == true ? value! : 'Not provided'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile picture
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        userData?['profilePicUrl'] ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Name
                  Text(
                    userData?['fullName'] ?? 'Your Name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Bio
                  Text(
                    userData?['bio'] ?? 'Write something about yourself...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Divider(),

                  // User Info Tiles
                  _buildInfoTile(
                      Icons.email, "Email", _auth.currentUser?.email),
                  _buildInfoTile(
                      Icons.phone, "Phone Number", userData?['phone']),
                  _buildInfoTile(
                      Icons.location_on, "Location", userData?['location']),
                  _buildInfoTile(
                      Icons.language, "Preferred Language", "English"),
                  SizedBox(height: 30),

                  // Edit Profile Button
                  ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Edit Profile'),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      );
                      if (result == true) {
                        fetchUserData();
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
