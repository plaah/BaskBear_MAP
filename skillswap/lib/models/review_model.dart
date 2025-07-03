import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String instructorId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int clarityScore;
  final int relevanceScore;
  final int satisfactionScore;

  ReviewModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.instructorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.clarityScore,
    required this.relevanceScore,
    required this.satisfactionScore,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      sessionId: map['sessionId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      instructorId: map['instructorId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      clarityScore: map['clarityScore'] ?? 0,
      relevanceScore: map['relevanceScore'] ?? 0,
      satisfactionScore: map['satisfactionScore'] ?? 0,
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      return dateValue;
    } else {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'instructorId': instructorId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'clarityScore': clarityScore,
      'relevanceScore': relevanceScore,
      'satisfactionScore': satisfactionScore,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? studentName,
    String? instructorId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? clarityScore,
    int? relevanceScore,
    int? satisfactionScore,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      instructorId: instructorId ?? this.instructorId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      clarityScore: clarityScore ?? this.clarityScore,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      satisfactionScore: satisfactionScore ?? this.satisfactionScore,
    );
  }

  @override
  String toString() {
    return 'ReviewModel{id: $id, sessionId: $sessionId, studentName: $studentName, rating: $rating}';
  }
}
