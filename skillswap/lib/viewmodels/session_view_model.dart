import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_model.dart';

class SessionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  List<Session> _sessions = [];
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;

  List<Session> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get selectedImage => _selectedImage;

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile, String sessionId) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (!imageFile.existsSync()) {
        throw Exception('Selected image file does not exist');
      }

      String fileName = 'session_images/${_auth.currentUser!.uid}/${sessionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'sessionId': sessionId,
          'instructorId': _auth.currentUser!.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      UploadTask uploadTask = ref.putFile(imageFile, metadata);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // FIXED: Get instructor information with proper error handling and debugging
  Future<Map<String, String>?> _getInstructorInfo() async {
    try {
      if (_auth.currentUser == null) {
        debugPrint('ERROR: User not authenticated');
        throw Exception('User not authenticated');
      }

      String currentUserId = _auth.currentUser!.uid;
      debugPrint('Current user ID: $currentUserId');

      // First check instructors collection
      DocumentSnapshot instructorDoc = await _firestore
          .collection('instructors')
          .doc(currentUserId)
          .get();

      debugPrint('Instructor doc exists: ${instructorDoc.exists}');

      if (instructorDoc.exists) {
        Map<String, dynamic> data = instructorDoc.data() as Map<String, dynamic>;
        debugPrint('Instructor data: $data');
        
        String instructorName = data['fullName'] ?? data['name'] ?? 'Unknown Instructor';
        debugPrint('Instructor name: $instructorName');
        
        return {
          'instructorId': currentUserId,
          'instructorName': instructorName,
        };
      }

      // Fallback to users collection
      debugPrint('Checking users collection...');
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      debugPrint('User doc exists: ${userDoc.exists}');

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        debugPrint('User data: $data');
        
        String userName = data['fullName'] ?? data['name'] ?? data['displayName'] ?? 'Unknown User';
        debugPrint('User name: $userName');
        
        return {
          'instructorId': currentUserId,
          'instructorName': userName,
        };
      }

      // If no document found, use Firebase Auth display name as fallback
      debugPrint('No document found, using Firebase Auth data...');
      String fallbackName = _auth.currentUser!.displayName ?? 
                           _auth.currentUser!.email?.split('@')[0] ?? 
                           'Unknown User';
      
      debugPrint('Fallback name: $fallbackName');
      
      return {
        'instructorId': currentUserId,
        'instructorName': fallbackName,
      };

    } catch (e) {
      debugPrint('Error getting instructor info: $e');
      
      // Last resort fallback
      if (_auth.currentUser != null) {
        return {
          'instructorId': _auth.currentUser!.uid,
          'instructorName': _auth.currentUser!.email ?? 'Unknown User',
        };
      }
      
      throw Exception('Failed to get instructor information: $e');
    }
  }

  // Create session with proper instructor info
  Future<void> createSession({
    required String title,
    required String description,
    required String category,
    required bool isOnline,
    String? location,
    String? meetingUrl,
    required double price,
    required DateTime startDate,
    DateTime? endDate,
    required int durationHours,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate authentication first
      if (_auth.currentUser == null) {
        throw Exception('You must be logged in to create a session');
      }

      // Validate required fields
      if (isOnline && (meetingUrl == null || meetingUrl.isEmpty)) {
        throw Exception('Meeting URL is required for online sessions');
      }
      
      if (!isOnline && (location == null || location.isEmpty)) {
        throw Exception('Location is required for in-person sessions');
      }

      // Get instructor information
      debugPrint('Getting instructor information...');
      Map<String, String>? instructorInfo = await _getInstructorInfo();
      if (instructorInfo == null) {
        throw Exception('Unable to get instructor information');
      }

      debugPrint('Instructor info retrieved: $instructorInfo');

      // Generate a unique session ID
      String sessionId = _firestore.collection('sessions').doc().id;

      String imageUrl = '';

      // Upload image if selected
      if (_selectedImage != null) {
        try {
          String? uploadedImageUrl = await _uploadImage(_selectedImage!, sessionId);
          if (uploadedImageUrl != null) {
            imageUrl = uploadedImageUrl;
          }
        } catch (uploadError) {
          debugPrint('Image upload failed, continuing without image: $uploadError');
          _error = 'Warning: Image upload failed, but session was created without image';
        }
      }

      // Create session data
      Map<String, dynamic> sessionData = {
        'id': sessionId,
        'title': title,
        'instructor': instructorInfo['instructorName']!, // This should now be correct
        'instructorId': instructorInfo['instructorId']!,
        'description': description,
        'category': category,
        'isOnline': isOnline,
        'location': location,
        'meetingUrl': meetingUrl,
        'price': price,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'durationHours': durationHours,
        'image': imageUrl,
        'isBooked': false,
        'rating': 0.0,
        'status': 'scheduled', // Add status
        'enrolledStudentId': null,
        'enrolledStudentName': null,
        'enrolledAt': null,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      debugPrint('Creating session with data: $sessionData');

      // Save to Firestore
      await _firestore.collection('sessions').doc(sessionId).set(sessionData);

      // Clear selected image after successful creation
      _selectedImage = null;

      // Reload sessions to refresh the list
      await loadSessions();

      debugPrint('Session created successfully: $sessionId');

    } catch (e) {
      _error = 'Failed to create session: $e';
      debugPrint('Error creating session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load sessions from Firestore
  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sessions')
          .orderBy('createdAt', descending: true)
          .get();

      _sessions = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Session(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          instructor: data['instructor'] ?? 'Unknown',
          instructorId: data['instructorId'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          isOnline: data['isOnline'] ?? true,
          location: data['location'],
          meetingUrl: data['meetingUrl'],
          price: (data['price'] ?? 0).toDouble(),
          startDate: data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : DateTime.now(),
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          durationHours: data['durationHours'] ?? 0,
          image: data['image'] ?? '',
          isBooked: data['isBooked'] ?? false,
          rating: (data['rating'] ?? 0.0).toDouble(),
          status: data['status'] ?? 'scheduled',
          enrolledStudentId: data['enrolledStudentId'],
          enrolledStudentName: data['enrolledStudentName'],
          enrolledAt: data['enrolledAt'] != null
              ? (data['enrolledAt'] as Timestamp).toDate()
              : null,
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();

    } catch (e) {
      _error = 'Failed to load sessions: $e';
      debugPrint('Error loading sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enroll student in session
  Future<void> enrollStudent(String sessionId, String studentId, String studentName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'enrolledStudentId': studentId,
        'enrolledStudentName': studentName,
        'enrolledAt': Timestamp.now(),
        'isBooked': true,
        'updatedAt': Timestamp.now(),
      });
      
      await loadSessions();
      debugPrint('Student enrolled successfully');
    } catch (e) {
      _error = 'Failed to enroll student: $e';
      debugPrint('Error enrolling student: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update session
  Future<void> updateSession(Session updatedSession) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> sessionData = {
        'title': updatedSession.title,
        'instructor': updatedSession.instructor,
        'instructorId': updatedSession.instructorId,
        'description': updatedSession.description,
        'category': updatedSession.category,
        'isOnline': updatedSession.isOnline,
        'location': updatedSession.location,
        'meetingUrl': updatedSession.meetingUrl,
        'price': updatedSession.price,
        'startDate': Timestamp.fromDate(updatedSession.startDate),
        'endDate': updatedSession.endDate != null
            ? Timestamp.fromDate(updatedSession.endDate!)
            : null,
        'durationHours': updatedSession.durationHours,
        'image': updatedSession.image,
        'isBooked': updatedSession.isBooked,
        'rating': updatedSession.rating,
        'status': updatedSession.status,
        'enrolledStudentId': updatedSession.enrolledStudentId,
        'enrolledStudentName': updatedSession.enrolledStudentName,
        'enrolledAt': updatedSession.enrolledAt != null
            ? Timestamp.fromDate(updatedSession.enrolledAt!)
            : null,
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('sessions').doc(updatedSession.id).update(sessionData);

      int index = _sessions.indexWhere((session) => session.id == updatedSession.id);
      if (index != -1) {
        _sessions[index] = updatedSession;
      }

      debugPrint('Session updated successfully: ${updatedSession.id}');

    } catch (e) {
      _error = 'Failed to update session: $e';
      debugPrint('Error updating session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark session as completed
  Future<void> markSessionCompleted(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'completed',
        'updatedAt': Timestamp.now(),
      });
      
      await loadSessions();
      debugPrint('Session marked as completed');
    } catch (e) {
      _error = 'Failed to mark session as completed: $e';
      debugPrint('Error marking session as completed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel session
  Future<void> cancelSession(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'cancelled',
        'enrolledStudentId': null,
        'enrolledStudentName': null,
        'enrolledAt': null,
        'isBooked': false,
        'updatedAt': Timestamp.now(),
      });
      
      await loadSessions();
      debugPrint('Session cancelled successfully');
    } catch (e) {
      _error = 'Failed to cancel session: $e';
      debugPrint('Error cancelling session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      Session? sessionToDelete = _sessions.firstWhereOrNull(
        (session) => session.id == sessionId,
      );

      // Delete image from Firebase Storage if it exists
      if (sessionToDelete?.image != null && 
          sessionToDelete!.image.isNotEmpty && 
          sessionToDelete.image.startsWith('https://')) {
        try {
          Reference ref = _storage.refFromURL(sessionToDelete.image);
          await ref.delete();
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }
      }

      // Delete session from Firestore
      await _firestore.collection('sessions').doc(sessionId).delete();

      // Remove from local list
      _sessions.removeWhere((session) => session.id == sessionId);

    } catch (e) {
      _error = 'Failed to delete session: $e';
      debugPrint('Error deleting session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear selected image
  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Extension to add firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}