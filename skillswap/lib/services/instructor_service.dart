// lib/services/instructor_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/models/instructor_model.dart';

class InstructorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createInstructorProfile(InstructorModel instructor) async {
    await _firestore.collection('instructors').doc(instructor.uid).set(instructor.toMap());
  }

  Future<InstructorModel?> getInstructorProfile(String uid) async {
    final doc = await _firestore.collection('instructors').doc(uid).get();
    if (doc.exists) {
      return InstructorModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateInstructorProfile(InstructorModel instructor) async {
    await _firestore.collection('instructors').doc(instructor.uid).update(instructor.toMap());
  }

  Future<void> deleteInstructorProfile(String uid) async {
    await _firestore.collection('instructors').doc(uid).delete();
  }
}