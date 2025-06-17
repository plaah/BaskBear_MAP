import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/session_model.dart';

class SessionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
      // Create a unique filename
      String fileName = 'session_images/${sessionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Firebase Storage
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Create session with image upload
  Future<void> createSession({
    required String title,
    required String description,
    required String category,
    required bool isOnline,
    String? location,
    required double price,
    required DateTime startDate,
    DateTime? endDate,
    required int durationHours,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generate a unique session ID
      String sessionId = _firestore.collection('sessions').doc().id;

      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!, sessionId);
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
      }

      // Create session data
      Map<String, dynamic> sessionData = {
        'id': sessionId,
        'title': title,
        'description': description,
        'category': category,
        'isOnline': isOnline,
        'location': location,
        'price': price,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'durationHours': durationHours,
        'image': imageUrl ?? '', // Store the download URL or empty string
        'isBooked': false,
        'createdAt': Timestamp.now(),
      };

      // Save to Firestore
      await _firestore.collection('sessions').doc(sessionId).set(sessionData);

      // Clear selected image after successful upload
      _selectedImage = null;

      // Reload sessions to refresh the list
      await loadSessions();

    } catch (e) {
      _error = 'Failed to create session: $e';
      print('Error creating session: $e');
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
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          isOnline: data['isOnline'] ?? true,
          location: data['location'],
          price: (data['price'] ?? 0).toDouble(),
          startDate: data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : DateTime.now(),
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          durationHours: data['durationHours'] ?? 0,
          image: data['image'] ?? '', // This will be the Firebase Storage URL
          isBooked: data['isBooked'] ?? false,
        );
      }).toList();

    } catch (e) {
      _error = 'Failed to load sessions: $e';
      print('Error loading sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update session - ADD THIS METHOD
  Future<void> updateSession(Session updatedSession) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert DateTime objects to Timestamp for Firestore
      Map<String, dynamic> sessionData = {
        'id': updatedSession.id,
        'title': updatedSession.title,
        'description': updatedSession.description,
        'category': updatedSession.category,
        'isOnline': updatedSession.isOnline,
        'location': updatedSession.location,
        'price': updatedSession.price,
        'startDate': updatedSession.startDate != null
            ? Timestamp.fromDate(updatedSession.startDate!)
            : null,
        'endDate': updatedSession.endDate != null
            ? Timestamp.fromDate(updatedSession.endDate!)
            : null,
        'durationHours': updatedSession.durationHours,
        'image': updatedSession.image,
        'isBooked': updatedSession.isBooked,
        'updatedAt': Timestamp.now(),
      };

      // Update in Firestore
      await _firestore.collection('sessions').doc(updatedSession.id).update(sessionData);

      // Update in local list
      int index = _sessions.indexWhere((session) => session.id == updatedSession.id);
      if (index != -1) {
        _sessions[index] = updatedSession;
      }

    } catch (e) {
      _error = 'Failed to update session: $e';
      print('Error updating session: $e');
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
      // Find the session to get image URL
      Session? sessionToDelete = _sessions.firstWhere(
            (session) => session.id == sessionId,
        orElse: () => Session(
          id: '',
          title: '',
          description: '',
          category: '',
          isOnline: true,
          price: 0,
          startDate: DateTime.now(),
          durationHours: 0,
          image: '',
          isBooked: false,
        ),
      );

      // Delete image from Firebase Storage if it exists
      if (sessionToDelete.image.isNotEmpty && sessionToDelete.image.startsWith('https://')) {
        try {
          Reference ref = _storage.refFromURL(sessionToDelete.image);
          await ref.delete();
        } catch (e) {
          print('Error deleting image: $e');
          // Continue with session deletion even if image deletion fails
        }
      }

      // Delete session from Firestore
      await _firestore.collection('sessions').doc(sessionId).delete();

      // Remove from local list
      _sessions.removeWhere((session) => session.id == sessionId);

    } catch (e) {
      _error = 'Failed to delete session: $e';
      print('Error deleting session: $e');
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