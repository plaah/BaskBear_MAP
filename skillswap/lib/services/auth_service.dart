import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/instructor_model.dart';
import '../models/student_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<StudentModel> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required String location,
  }) async {
    UserCredential? credential;
    
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final data = {
        'email': email,
        'fullName': fullName,
        'location': location,
        'userType': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('students').doc(credential.user!.uid).set(data);

      final generalUserData = {
        'email': email,
        'fullName': fullName,
        'location': location,
        'userType': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(generalUserData);

      return StudentModel(
        uid: credential.user!.uid,
        email: email,
        fullName: fullName,
        location: location,
      );
    } catch (e) {
      // Clean up if user was created but data save failed
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (deleteError) {
          print('Failed to delete user after signup error: $deleteError');
        }
      }
      throw Exception('Student signup failed: $e');
    }
  }

  Future<InstructorModel> signUpInstructor({
    required String email,
    required String password,
    required String fullName,
    required String location,
    File? profileImage,
    List<String>? skills,
    int? yearsExperience,
    String? workLink,
    String? description,
    List<String>? certifications,
  }) async {
    UserCredential? credential;
    String? imageUrl;
    
    try {
      // Create user account first
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Upload profile image if provided
      if (profileImage != null) {
        try {
          imageUrl = await _uploadProfileImage(profileImage, credential.user!.uid);
        } catch (uploadError) {
          print('Profile image upload failed: $uploadError');
          // Continue without image rather than failing completely
          imageUrl = null;
        }
      }

      // Save user data to Firestore
      final data = {
        'email': email,
        'fullName': fullName,
        'location': location,
        'userType': 'instructor',
        'profileImage': imageUrl,
        'skills': skills ?? [],
        'yearsExperience': yearsExperience,
        'workLink': workLink,
        'description': description,
        'certifications': certifications ?? [],
        'isApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('instructors').doc(credential.user!.uid).set(data);


      final generalUserData = {
        'email': email,
        'fullName': fullName,
        'location': location,
        'userType': 'instructor',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(generalUserData);

      return InstructorModel(
        uid: credential.user!.uid,
        email: email,
        fullName: fullName,
        location: location,
        profileImage: imageUrl,
        skills: skills,
        yearsExperience: yearsExperience,
        workLink: workLink,
        description: description,
        certifications: certifications,
        isApproved: false,
      );
    } catch (e) {
      // Clean up if user was created but subsequent operations failed
      if (credential?.user != null) {
        try {
          // Delete uploaded image if it exists
          if (imageUrl != null) {
            await _deleteProfileImage(credential!.user!.uid);
          }
          // Delete user account
          await credential!.user!.delete();
        } catch (cleanupError) {
          print('Failed to cleanup after instructor signup error: $cleanupError');
        }
      }
      throw Exception('Instructor signup failed: $e');
    }
  }

  Future<String> _uploadProfileImage(File image, String userId) async {
    try {
      // Create a unique filename with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('profile_images/$userId/profile_$timestamp.jpg');
      
      // Set metadata for better file handling
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': timestamp.toString(),
        },
      );

      final uploadTask = ref.putFile(image, metadata);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<void> _deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId');
      await ref.delete();
    } catch (e) {
      print('Failed to delete profile image: $e');
      // Don't throw here as this is cleanup
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}