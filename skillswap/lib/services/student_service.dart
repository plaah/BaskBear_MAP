import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/models/student_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create student profile in 'students' collection
  Future<void> createStudentProfile(StudentModel student) async {
    try {
      await _firestore.collection('students').doc(student.uid).set(student.toMap());
    } catch (e) {
      throw Exception('Failed to create student profile: $e');
    }
  }

  // Get single student data by UID
  Future<StudentModel?> getStudentProfile(String uid) async {
    try {
      final doc = await _firestore.collection('students').doc(uid).get();
      if (doc.exists) {
        return StudentModel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch student profile: $e');
    }
  }

  // Update student data
  Future<void> updateStudentProfile(StudentModel student) async {
    try {
      await _firestore.collection('students').doc(student.uid).update(student.toMap());
    } catch (e) {
      throw Exception('Failed to update student profile: $e');
    }
  }

  // Delete student data
  Future<void> deleteStudentProfile(String uid) async {
    try {
      await _firestore.collection('students').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete student profile: $e');
    }
  }

  // Real-time stream of student document
  Stream<DocumentSnapshot> getStudentStream(String uid) {
    return _firestore.collection('students').doc(uid).snapshots();
  }
}
