import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentViewModel with ChangeNotifier {
  final StudentService _studentService = StudentService();
  StudentModel? _student;

  StudentModel? get student => _student;

  // Fetch data student sekali (bukan stream)
  Future<void> fetchStudentProfile(String uid) async {
    try {
      final fetchedStudent = await _studentService.getStudentProfile(uid);
      _student = fetchedStudent;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch student profile: $e');
    }
  }

  // Create student baru
  Future<void> createStudentProfile(StudentModel student) async {
    try {
      await _studentService.createStudentProfile(student);
      _student = student;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create student profile: $e');
    }
  }

  // Update student
  Future<void> updateStudentProfile(StudentModel student) async {
    try {
      await _studentService.updateStudentProfile(student);
      _student = student;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update student profile: $e');
    }
  }

  // Delete student
  Future<void> deleteStudentProfile(String uid) async {
    try {
      await _studentService.deleteStudentProfile(uid);
      _student = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete student profile: $e');
    }
  }
}
