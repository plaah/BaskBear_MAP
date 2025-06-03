import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skillswap/viewmodels/auth_view_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();

  // Instructor-specific controllers
  final _skillsController = TextEditingController();
  final _yearsController = TextEditingController();
  final _workLinkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _certificationController = TextEditingController();

  String? _selectedRole;
  File? _profileImage;
  final List<String> _skills = [];
  final List<String> _certifications = [];
  bool _passwordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    _yearsController.dispose();
    _workLinkController.dispose();
    _descriptionController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _profileImage = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _addSkill() {
    final skill = _skillsController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillsController.clear();
      });
    }
  }

  void _addCertification() {
    final cert = _certificationController.text.trim();
    if (cert.isNotEmpty && !_certifications.contains(cert)) {
      setState(() {
        _certifications.add(cert);
        _certificationController.clear();
      });
    }
  }

  Future<void> _signupStudent(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final student = await authViewModel.signUpStudent(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      location: _locationController.text.trim(),
    );

    if (student != null && context.mounted) {
      // Navigate to student dashboard or show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Navigate to appropriate screen
      // Navigator.pushReplacementNamed(context, '/student-dashboard');
    }
  }

  Future<void> _signupInstructor(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate instructor-specific fields
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one skill')),
      );
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final instructor = await authViewModel.signUpInstructor(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      location: _locationController.text.trim(),
      profileImage: _profileImage,
      skills: _skills,
      yearsExperience: int.tryParse(_yearsController.text),
      workLink: _workLinkController.text.trim(),
      description: _descriptionController.text.trim(),
      certifications: _certifications,
    );

    if (instructor != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instructor account created! Awaiting approval.'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Navigate to appropriate screen
      // Navigator.pushReplacementNamed(context, '/instructor-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sign Up'), elevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Text(
                    'Create Your Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Common fields
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Full name is required';
                      if (v.trim().length < 2)
                        return 'Name must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Email is required';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(v)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: !_passwordVisible,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (City)',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Location is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'I want to join as',
                      prefixIcon: Icon(Icons.group),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('Student'),
                      ),
                      DropdownMenuItem(
                        value: 'instructor',
                        child: Text('Instructor'),
                      ),
                    ],
                    onChanged: (role) => setState(() => _selectedRole = role),
                    validator: (v) => v == null ? 'Please select a role' : null,
                  ),
                  const SizedBox(height: 24),

                  // Instructor-specific fields
                  if (_selectedRole == 'instructor') ...[
                    const Divider(),
                    const Text(
                      'Instructor Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile image
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                            child:
                                _profileImage == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.upload),
                            label: Text(
                              _profileImage == null
                                  ? 'Upload Profile Photo'
                                  : 'Change Photo',
                            ),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Skills
                    TextFormField(
                      controller: _skillsController,
                      decoration: InputDecoration(
                        labelText: 'Add Skills',
                        hintText: 'e.g., Flutter, Java, Web Development',
                        prefixIcon: const Icon(Icons.star),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addSkill,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                    if (_skills.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            _skills
                                .map(
                                  (skill) => Chip(
                                    label: Text(skill),
                                    onDeleted:
                                        () => setState(
                                          () => _skills.remove(skill),
                                        ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _yearsController,
                      decoration: const InputDecoration(
                        labelText: 'Years of Experience',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Experience is required';
                        final years = int.tryParse(v);
                        if (years == null || years < 0)
                          return 'Please enter valid years';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _workLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Professional Link',
                        hintText: 'LinkedIn, Portfolio, or CV link',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Professional link is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'About You',
                        hintText: 'Describe what type of instructor you are',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Description is required';
                        if (v.trim().length < 20)
                          return 'Please provide more details (at least 20 characters)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Certifications
                    TextFormField(
                      controller: _certificationController,
                      decoration: InputDecoration(
                        labelText: 'Add Certification Links (Optional)',
                        hintText: 'Link to your certificates',
                        prefixIcon: const Icon(Icons.verified),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addCertification,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addCertification(),
                    ),
                    if (_certifications.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            _certifications
                                .map(
                                  (cert) => Chip(
                                    label: Text(
                                      cert,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onDeleted:
                                        () => setState(
                                          () => _certifications.remove(cert),
                                        ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],

                  // Sign up button
                  if (_selectedRole != null) ...[
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            authViewModel.isLoading
                                ? null
                                : () {
                                  if (_selectedRole == 'student') {
                                    _signupStudent(context);
                                  } else {
                                    _signupInstructor(context);
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            authViewModel.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  _selectedRole == 'student'
                                      ? 'Sign Up as Student'
                                      : 'Sign Up as Instructor',
                                  style: const TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Error message
                  if (authViewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authViewModel.errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Success message
                  if (authViewModel.successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authViewModel.successMessage!,
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to sign in screen
                          // Navigator.pushReplacementNamed(context, '/signin');
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
