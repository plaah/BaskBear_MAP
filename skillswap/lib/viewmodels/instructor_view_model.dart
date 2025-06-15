// lib/viewmodels/instructor_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:skillswap/models/instructor_model.dart';
import 'package:skillswap/services/instructor_service.dart';

class InstructorViewModel with ChangeNotifier {
  final InstructorService _instructorService = InstructorService();

  // Ganti 'U0srNN1vtjwWD9D9aDuD' dengan UID instruktur yang sesuai
  final String instructorUid = 'U0srNN1vtjwWD9D9aDuD';

  Future<void> createInstructorProfile(InstructorModel instructor) async {
    await _instructorService.createInstructorProfile(instructor);
    notifyListeners();
  }

  Future<InstructorModel?> getInstructorProfile(String uid) async {
    return _instructorService.getInstructorProfile(uid);
  }

  Future<void> updateInstructorProfile(InstructorModel instructor) async {
    await _instructorService.updateInstructorProfile(instructor);
    notifyListeners();
  }

  Future<void> deleteInstructorProfile(String uid) async {
    await _instructorService.deleteInstructorProfile(uid);
    notifyListeners();
  }
}