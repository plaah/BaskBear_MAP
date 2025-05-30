import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not logged in
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No user logged in.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return Center(
              child: Text(
                'Profile not found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Use a default avatar if none is set
          final avatarUrl =
              data['avatarUrl'] ??
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(data['fullName'] ?? 'User')}&background=0D8ABC&color=fff';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: Colors.grey[900],
                ),
                const SizedBox(height: 20),
                Text(
                  data['fullName'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data['bio'] ?? 'Student',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                _buildProfileItem(Icons.email, data['email'] ?? ''),
                _buildProfileItem(Icons.phone, data['phone'] ?? 'Not set'),
                _buildProfileItem(
                  Icons.school,
                  data['university'] ?? 'Not set',
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // TODO: Implement edit profile functionality
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildProfileItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 20),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
