// lib/viewmodels/instructor_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/models/instructor_model.dart';
import 'package:skillswap/services/instructor_service.dart';

class InstructorViewModel with ChangeNotifier {
  final InstructorService _instructorService = InstructorService();

  InstructorModel? _instructor;
  InstructorModel? get instructor => _instructor;

  // 🆕 Fetch current logged-in instructor profile
  Future<void> fetchInstructorProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _instructor = await _instructorService.getInstructorProfile(uid);
      notifyListeners();
    } else {
      throw Exception("User not logged in");
    }
  }

  // ✅ Create instructor profile
  Future<void> createInstructorProfile(InstructorModel instructor) async {
    await _instructorService.createInstructorProfile(instructor);
    _instructor = instructor;
    notifyListeners();
  }

  // ✅ Get instructor profile by UID (manual, tanpa simpan ke state)
  Future<InstructorModel?> getInstructorProfile(String uid) async {
    return _instructorService.getInstructorProfile(uid);
  }

  // ✅ Update instructor profile
  Future<void> updateInstructorProfile(InstructorModel instructor) async {
    await _instructorService.updateInstructorProfile(instructor);
    _instructor = instructor;
    notifyListeners();
  }

  // ✅ Delete instructor profile
  Future<void> deleteInstructorProfile(String uid) async {
    await _instructorService.deleteInstructorProfile(uid);
    _instructor = null;
    notifyListeners();
  }
}
