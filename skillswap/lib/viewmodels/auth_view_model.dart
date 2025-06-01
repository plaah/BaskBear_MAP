import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/instructor_model.dart';
import '../models/student_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  AuthViewModel(this._authService);

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  Future<StudentModel?> signUpStudent({
    required String fullName,
    required String email,
    required String password,
    required String location,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final student = await _authService.signUpStudent(
        email: email,
        password: password,
        fullName: fullName,
        location: location,
      );
      successMessage = 'Student account created successfully!';
      return student;
    } catch (e) {
      errorMessage = _formatErrorMessage(e.toString());
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<InstructorModel?> signUpInstructor({
    required String fullName,
    required String email,
    required String password,
    required String location,
    File? profileImage,
    List<String>? skills,
    int? yearsExperience,
    String? workLink,
    String? description,
    List<String>? certifications,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final instructor = await _authService.signUpInstructor(
        email: email,
        password: password,
        fullName: fullName,
        location: location,
        profileImage: profileImage,
        skills: skills,
        yearsExperience: yearsExperience,
        workLink: workLink,
        description: description,
        certifications: certifications,
      );
      successMessage = 'Instructor account created successfully! Awaiting approval.';
      return instructor;
    } catch (e) {
      errorMessage = _formatErrorMessage(e.toString());
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(email: email, password: password);
      if (user != null) {
        // Get user data from Firestore to determine user type
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          successMessage = 'Signed in successfully!';
          return {
            'user': user,
            'userType': userData['userType'],
            'userData': userData,
          };
        }
      }
      return null;
    } catch (e) {
      errorMessage = _formatErrorMessage(e.toString());
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Keep the old login method for backward compatibility
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    String? userType, // Deprecated parameter, will be ignored
  }) async {
    return await signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      successMessage = 'Signed out successfully!';
    } catch (e) {
      errorMessage = _formatErrorMessage(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      errorMessage = 'Please enter your email address';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      successMessage = 'Password reset email sent!';
      return true;
    } catch (e) {
      errorMessage = _formatErrorMessage(e.toString());
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatErrorMessage(String error) {
    // Remove "Exception: " prefix and make user-friendly
    error = error.replaceAll('Exception: ', '');
    
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please use a different email or sign in.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please use at least 6 characters.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment before trying again.';
    }
    
    return error;
  }
}
