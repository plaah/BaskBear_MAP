import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String email;
  final String fullName;
  final String location;

  StudentModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.location,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'location': location,
    };
  }
}