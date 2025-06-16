// lib/views/instructor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap/models/instructor_model.dart';
import 'package:skillswap/viewmodels/instructor_view_model.dart';

class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key});

  @override
  State<InstructorProfileScreen> createState() => _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch instructor data saat screen pertama kali muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InstructorViewModel>(context, listen: false).fetchInstructorProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final instructorViewModel = Provider.of<InstructorViewModel>(context);
    final instructor = instructorViewModel.instructor;

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
      body: instructor == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: instructor.profileImage != null
                  ? NetworkImage(instructor.profileImage!)
                  : const AssetImage('assets/instructor.jpeg') as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              instructor.fullName,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Senior Software Engineer',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            _buildProfileItem(Icons.email, instructor.email),
            _buildProfileItem(Icons.location_on, instructor.location),
            _buildProfileItem(
                Icons.work, '${instructor.yearsExperience ?? 0}+ years experience'),
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

  void _showEditProfileDialog(
      BuildContext context, InstructorViewModel instructorViewModel, InstructorModel instructor) {
    final TextEditingController fullNameController = TextEditingController(text: instructor.fullName);
    final TextEditingController emailController = TextEditingController(text: instructor.email);
    final TextEditingController locationController = TextEditingController(text: instructor.location);
    final TextEditingController yearsExperienceController =
    TextEditingController(text: instructor.yearsExperience?.toString() ?? '');

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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedInstructor = InstructorModel(
                  uid: instructor.uid,
                  email: emailController.text,
                  fullName: fullNameController.text,
                  location: locationController.text,
                  profileImage: instructor.profileImage,
                  skills: instructor.skills,
                  certifications: instructor.certifications,
                  workLink: instructor.workLink,
                  description: instructor.description,
                  isApproved: instructor.isApproved,
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
