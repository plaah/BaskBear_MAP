// lib/views/instructor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap/models/instructor_model.dart';
import 'package:skillswap/viewmodels/instructor_view_model.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final instructorViewModel = Provider.of<InstructorViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Instructor Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<InstructorModel?>(
        future: instructorViewModel.getInstructorProfile('some-uid'), // Replace with actual UID
        builder: (context, snapshot) {
          final instructor = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (instructor == null) {
            return const Center(child: Text('Profile not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/instructor.jpeg'),
                ),
                const SizedBox(height: 20),
                Text(
                  instructor.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Senior Software Engineer',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                _buildProfileItem(Icons.email, instructor.email),
                _buildProfileItem(Icons.phone, '+1 (987) 654-3210'),
                _buildProfileItem(Icons.work, '${instructor.yearsExperience}+ years experience'),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    _showEditProfileDialog(context, instructorViewModel, instructor);
                  },
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String text) {
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

  void _showEditProfileDialog(BuildContext context, InstructorViewModel instructorViewModel, InstructorModel instructor) {
    final TextEditingController fullNameController = TextEditingController(text: instructor.fullName);
    final TextEditingController emailController = TextEditingController(text: instructor.email);
    final TextEditingController locationController = TextEditingController(text: instructor.location);
    final TextEditingController yearsExperienceController = TextEditingController(text: instructor.yearsExperience.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: yearsExperienceController,
                  decoration: const InputDecoration(labelText: 'Years of Experience'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedInstructor = InstructorModel(
                  uid: instructor.uid,
                  email: emailController.text,
                  fullName: fullNameController.text,
                  location: locationController.text,
                  yearsExperience: int.tryParse(yearsExperienceController.text),
                );
                instructorViewModel.updateInstructorProfile(updatedInstructor);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}