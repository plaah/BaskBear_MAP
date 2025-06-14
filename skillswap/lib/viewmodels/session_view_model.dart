import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

class SessionViewModel extends ChangeNotifier {
  final SessionService _sessionService;
  List<Session> _sessions = [];
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;

  SessionViewModel(this._sessionService);

  // Getters
  List<Session> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get selectedImage => _selectedImage;

  // Image handling
  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _selectedImage = File(picked.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Image pick error: ${e.toString()}';
      notifyListeners();
    }
  }

  // Session operations
  Future<void> createSession({
    required String title,
    required String description,
    required String category,
    required bool isOnline,
    required String? location,
    required double price,
    required DateTime startDate,
    DateTime? endDate,
    required int durationHours,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newSession = Session(
        title: title,
        description: description,
        category: category,
        isOnline: isOnline,
        location: isOnline ? null : location,
        price: price,
        startDate: startDate,
        endDate: endDate,
        durationHours: durationHours,
        image: _selectedImage?.path ?? 'https://via.placeholder.com/150',
      );

      await _sessionService.createSession(newSession);
      await loadSessions();
    } catch (e) {
      _error = 'Create session failed: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      _selectedImage = null;
      notifyListeners();
    }
  }

  Future<void> loadSessions() async {
    try {
      _isLoading = true;
      notifyListeners();
      _sessions = await _sessionService.getSessions();
      _error = null;
    } catch (e) {
      _error = 'Load sessions failed: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionService.deleteSession(sessionId);
      await loadSessions();
    } catch (e) {
      _error = 'Delete session failed: ${e.toString()}';
      debugPrint(_error);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
