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

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
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

  late AnimationController _animationController;
  late AnimationController _roleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _roleSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _roleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _roleSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _roleAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _roleAnimationController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Failed to pick image: $e'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Student account created successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _signupInstructor(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please add at least one skill'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Instructor account created! Awaiting approval.'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    bool alignLabelWithHint = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          color: Color(0xFF2c3e50), // Dark text color for better readability
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF1565c0)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1565c0), width: 2),
          ),
          filled: true,
          fillColor: Colors.white, // Changed to white for better contrast
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          alignLabelWithHint: alignLabelWithHint,
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        obscureText: obscureText,
        maxLines: maxLines,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'Sign Up',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFF1565c0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Card(
                        elevation: 20,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey.shade50],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header
                                  const Text(
                                    'Create Your Account',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2c3e50),
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Join our learning community today',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),

                                  // Common fields
                                  _buildTextField(
                                    controller: _fullNameController,
                                    label: 'Full Name',
                                    icon: Icons.person_outline,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Full name is required';
                                      }
                                      if (v.trim().length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    obscureText: !_passwordVisible,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Password is required';
                                      if (v.length < 6) return 'Password must be at least 6 characters';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  _buildTextField(
                                    controller: _locationController,
                                    label: 'Location (City)',
                                    icon: Icons.location_on_outlined,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Location is required';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Role selection
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedRole,
                                      style: const TextStyle(
                                        color: Color(0xFF2c3e50), // Dark text color for dropdown
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'I want to join as',
                                        labelStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF667eea), Color(0xFF1565c0)],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.group_outlined, color: Colors.white, size: 20),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: Color(0xFF1565c0), width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white, // Changed to white for better contrast
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'student', child: Text('Student')),
                                        DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                                      ],
                                      onChanged: (role) {
                                        setState(() => _selectedRole = role);
                                        if (role == 'instructor') {
                                          _roleAnimationController.forward();
                                        } else {
                                          _roleAnimationController.reverse();
                                        }
                                      },
                                      validator: (v) => v == null ? 'Please select a role' : null,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Instructor-specific fields with animation
                                  AnimatedBuilder(
                                    animation: _roleSlideAnimation,
                                    builder: (context, child) {
                                      return SizeTransition(
                                        sizeFactor: _roleSlideAnimation,
                                        child: FadeTransition(
                                          opacity: _roleSlideAnimation,
                                          child: _selectedRole == 'instructor' ? _buildInstructorFields() : const SizedBox.shrink(),
                                        ),
                                      );
                                    },
                                  ),

                                  // Sign up button
                                  if (_selectedRole != null) ...[
                                    const SizedBox(height: 32),
                                    Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF667eea), Color(0xFF1565c0)],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF1565c0).withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: authViewModel.isLoading
                                            ? null
                                            : () {
                                                if (_selectedRole == 'student') {
                                                  _signupStudent(context);
                                                } else {
                                                  _signupInstructor(context);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: authViewModel.isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                _selectedRole == 'student'
                                                    ? 'Sign Up as Student'
                                                    : 'Sign Up as Instructor',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),

                                  // Error/Success messages
                                  if (authViewModel.errorMessage != null)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        border: Border.all(color: Colors.red.shade200),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.red.shade700),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              authViewModel.errorMessage!,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (authViewModel.successMessage != null)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        border: Border.all(color: Colors.green.shade200),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              authViewModel.successMessage!,
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 32),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Sign in link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                                          child: const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              color: Color(0xFF1565c0),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF1565c0)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Instructor Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
        ),

        // Profile image
        Center(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF1565c0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565c0).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: Text(
                    _profileImage == null ? 'Upload Profile Photo' : 'Change Photo',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Skills
        _buildTextField(
          controller: _skillsController,
          label: 'Add Skills',
          icon: Icons.star_outline,
          hint: 'e.g., Flutter, Java, Web Development',
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF1565c0)),
            onPressed: _addSkill,
          ),
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) => Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF1565c0)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Chip(
                label: Text(skill, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                deleteIconColor: Colors.white,
                onDeleted: () => setState(() => _skills.remove(skill)),
              ),
            )).toList(),
          ),
        ],
        const SizedBox(height: 20),

        _buildTextField(
          controller: _yearsController,
          label: 'Years of Experience',
          icon: Icons.work_outline,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Experience is required';
            final years = int.tryParse(v);
            if (years == null || years < 0) return 'Please enter valid years';
            return null;
          },
        ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _workLinkController,
          label: 'Professional Link',
          icon: Icons.link,
          hint: 'LinkedIn, Portfolio, or CV link',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Professional link is required';
            return null;
          },
        ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _descriptionController,
          label: 'About You',
          icon: Icons.description_outlined,
          hint: 'Describe what type of instructor you are',
          maxLines: 3,
          alignLabelWithHint: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Description is required';
            if (v.trim().length < 20) return 'Please provide more details (at least 20 characters)';
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Certifications
        _buildTextField(
          controller: _certificationController,
          label: 'Add Certification Links (Optional)',
          icon: Icons.verified_outlined,
          hint: 'Link to your certificates',
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF1565c0)),
            onPressed: _addCertification,
          ),
        ),
        if (_certifications.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _certifications.map((cert) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Chip(
                label: Text(
                  cert,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
                deleteIconColor: Colors.white,
                onDeleted: () => setState(() => _certifications.remove(cert)),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}