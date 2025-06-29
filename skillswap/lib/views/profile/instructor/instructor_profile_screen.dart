import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap/models/instructor_model.dart';
import 'package:skillswap/viewmodels/instructor_view_model.dart';

class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key});

  @override
  State<InstructorProfileScreen> createState() =>
      _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InstructorViewModel>(
        context,
        listen: false,
      ).fetchInstructorProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final instructorViewModel = Provider.of<InstructorViewModel>(context);
    final instructor = instructorViewModel.instructor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        centerTitle: true,
        title: const Text(
          'Instructor Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          instructor == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              0,
                              40,
                              109,
                            ).withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (instructor.profileImage != null &&
                                    instructor.profileImage!.isNotEmpty)
                                ? NetworkImage(instructor.profileImage!)
                                : const AssetImage('assets/instructor.jpeg')
                                    as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Name and status
                    Text(
                      instructor.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 2, 39, 103),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            instructor.isApproved
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              instructor.isApproved
                                  ? Colors.green
                                  : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        instructor.isApproved ? 'Approved' : 'Pending Approval',
                        style: TextStyle(
                          color:
                              instructor.isApproved
                                  ? Colors.green
                                  : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile Info Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      color: const Color.fromARGB(255, 140, 205, 255),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            _profileItem(
                              Icons.email,
                              instructor.email,
                              context,
                            ),
                            const SizedBox(height: 8),
                            _profileItem(
                              Icons.location_on,
                              instructor.location,
                              context,
                            ),
                            const SizedBox(height: 8),
                            _profileItem(
                              Icons.work,
                              '${instructor.yearsExperience ?? 0}+ years experience',
                              context,
                            ),
                            if (instructor.workLink != null &&
                                instructor.workLink!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _profileItem(
                                Icons.link,
                                instructor.workLink!,
                                context,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // About
                    _sectionTitle('About You'),
                    _sectionContent(instructor.description ?? ''),
                    const SizedBox(height: 20),
                    // Skills
                    _sectionTitle('Skills'),
                    (instructor.skills == null || instructor.skills!.isEmpty)
                        ? const Text(
                          'No skills added',
                          style: TextStyle(color: Colors.black54),
                        )
                        : Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children:
                              instructor.skills!
                                  .map(
                                    (skill) => Chip(
                                      label: Text(
                                        skill,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        0,
                                        33,
                                        88,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    const SizedBox(height: 20),
                    // Certifications
                    _sectionTitle('Certifications'),
                    (instructor.certifications == null ||
                            instructor.certifications!.isEmpty)
                        ? const Text(
                          'No certifications added',
                          style: TextStyle(color: Colors.black54),
                        )
                        : Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children:
                              instructor.certifications!
                                  .map(
                                    (cert) => Chip(
                                      label: Text(
                                        cert.length > 30
                                            ? '${cert.substring(0, 30)}...'
                                            : cert,
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      backgroundColor: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    const SizedBox(height: 32),
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            84,
                            138,
                            232,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 52),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          _showEditProfileDialog(
                            context,
                            instructorViewModel,
                            instructor,
                          );
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _profileItem(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    InstructorViewModel instructorViewModel,
    InstructorModel instructor,
  ) {
    final fullNameController = TextEditingController(text: instructor.fullName);
    final emailController = TextEditingController(text: instructor.email);
    final locationController = TextEditingController(text: instructor.location);
    final yearsExperienceController = TextEditingController(
      text: instructor.yearsExperience?.toString() ?? '',
    );
    final workLinkController = TextEditingController(
      text: instructor.workLink ?? '',
    );
    final descriptionController = TextEditingController(
      text: instructor.description ?? '',
    );

    List<String> skills = List<String>.from(instructor.skills ?? []);
    List<String> certifications = List<String>.from(
      instructor.certifications ?? [],
    );
    final skillsController = TextEditingController();
    final certificationsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Edit Profile'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                      ),
                      TextField(
                        controller: yearsExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Years of Experience',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: workLinkController,
                        decoration: const InputDecoration(
                          labelText: 'Professional Link',
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'About You',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      // Skills input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: skillsController,
                              decoration: const InputDecoration(
                                labelText: 'Add Skill',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final skill = skillsController.text.trim();
                              if (skill.isNotEmpty && !skills.contains(skill)) {
                                setState(() {
                                  skills.add(skill);
                                  skillsController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children:
                            skills
                                .map(
                                  (skill) => Chip(
                                    label: Text(skill),
                                    onDeleted: () {
                                      setState(() {
                                        skills.remove(skill);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                      // Certifications input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: certificationsController,
                              decoration: const InputDecoration(
                                labelText: 'Add Certification',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final cert = certificationsController.text.trim();
                              if (cert.isNotEmpty &&
                                  !certifications.contains(cert)) {
                                setState(() {
                                  certifications.add(cert);
                                  certificationsController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children:
                            certifications
                                .map(
                                  (cert) => Chip(
                                    label: Text(
                                      cert.length > 30
                                          ? '${cert.substring(0, 30)}...'
                                          : cert,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        certifications.remove(cert);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
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
                        skills: skills,
                        certifications: certifications,
                        workLink: workLinkController.text,
                        description: descriptionController.text,
                        isApproved: instructor.isApproved,
                        yearsExperience: int.tryParse(
                          yearsExperienceController.text,
                        ),
                      );
                      instructorViewModel.updateInstructorProfile(
                        updatedInstructor,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
        );
      },
    );
  }
}
