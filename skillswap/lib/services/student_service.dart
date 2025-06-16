import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createStudent(StudentModel student) async {
    try {
      await _firestore.collection('users').doc(student.uid).set(student.toMap());
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  Future<void> updateStudent(StudentModel student) async {
    try {
      await _firestore.collection('users').doc(student.uid).update(student.toMap());
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  Future<void> deleteStudent(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  Stream<DocumentSnapshot> getStudentStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}