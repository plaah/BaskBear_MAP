import 'package:cloud_firestore/cloud_firestore.dart';

class InstructorModel {
  final String uid;
  final String email;
  final String fullName;
  final String location;
  final String? profileImage;
  final List<String>? skills;
  final int? yearsExperience;
  final String? workLink;
  final String? description;
  final List<String>? certifications;
  final bool isApproved;

  InstructorModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.location,
    this.profileImage,
    this.skills,
    this.yearsExperience,
    this.workLink,
    this.description,
    this.certifications,
    this.isApproved = false,
  });

  factory InstructorModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InstructorModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      location: data['location'] ?? '',
      profileImage: data['profileImage'],
      skills: data['skills'] != null ? List<String>.from(data['skills']) : null,
      yearsExperience: data['yearsExperience'],
      workLink: data['workLink'],
      description: data['description'],
      certifications: data['certifications'] != null ? List<String>.from(data['certifications']) : null,
      isApproved: data['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'location': location,
      'profileImage': profileImage,
      'skills': skills,
      'yearsExperience': yearsExperience,
      'workLink': workLink,
      'description': description,
      'certifications': certifications,
      'isApproved': isApproved,
    };
  }
}
