import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id; 
  final String title;
  final String instructor;
  final String instructorId;
  final String description;
  final String category;
  final bool isOnline;
  final String? location;
  final String? meetingUrl;
  final double price;
  final DateTime startDate;
  final DateTime? endDate;
  final double rating;
  final String image;
  final int durationHours;
  final bool isBooked;
  final String? enrolledStudentId; // Add enrolled student ID
  final String? enrolledStudentName; // Add enrolled student name for display
  final DateTime? enrolledAt; // Add enrollment timestamp
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.title,
    this.instructor = 'You',
    required this.instructorId,
    required this.description,
    required this.category,
    required this.isOnline,
    this.location,
    this.meetingUrl,
    required this.price,
    required this.startDate,
    this.endDate,
    this.rating = 0.0,
    this.isBooked = false,
    required this.image,
    required this.durationHours,
    this.enrolledStudentId,
    this.enrolledStudentName,
    this.enrolledAt,
    this.status = 'scheduled', // Default status
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get durationHour => '$durationHours ${durationHours == 1 ? 'hour' : 'hours'}';
  
  // Check if session is available for booking
  bool get isAvailable => !isBooked && enrolledStudentId == null && status == 'scheduled';
  
  // Check if session is completed
  bool get isCompleted => status == 'completed';

  // Fixed fromMap to handle both DateTime strings and Timestamps
  factory Session.fromMap(Map<String, dynamic> map, String id) {
    return Session(
      id: id,
      title: map['title'] ?? '',
      instructor: map['instructor'] ?? 'You',
      instructorId: map['instructorId'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      isOnline: map['isOnline'] ?? false,
      location: map['location'],
      meetingUrl: map['meetingUrl'],
      price: (map['price'] ?? 0.0).toDouble(),
      startDate: _parseDateTime(map['startDate']),
      endDate: map['endDate'] != null ? _parseDateTime(map['endDate']) : null,
      rating: (map['rating'] ?? 0.0).toDouble(),
      image: map['image'] ?? 'https://via.placeholder.com/150',
      durationHours: map['durationHours'] ?? 0,
      isBooked: map['isBooked'] ?? false,
      enrolledStudentId: map['enrolledStudentId'],
      enrolledStudentName: map['enrolledStudentName'],
      enrolledAt: map['enrolledAt'] != null ? _parseDateTime(map['enrolledAt']) : null,
      status: map['status'] ?? 'scheduled',
      createdAt: map['createdAt'] != null ? _parseDateTime(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? _parseDateTime(map['updatedAt']) : DateTime.now(),
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
      'title': title,
      'instructor': instructor,
      'instructorId': instructorId,
      'description': description,
      'category': category,
      'isOnline': isOnline,
      'isBooked': isBooked,
      'location': location,
      'meetingUrl': meetingUrl,
      'price': price,
      'startDate': Timestamp.fromDate(startDate), // Store as Timestamp for Firestore
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'rating': rating,
      'image': image,
      'durationHours': durationHours,
      'enrolledStudentId': enrolledStudentId,
      'enrolledStudentName': enrolledStudentName,
      'enrolledAt': enrolledAt != null ? Timestamp.fromDate(enrolledAt!) : null,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy method for easy updates
  Session copyWith({
    String? id,
    String? title,
    String? instructor,
    String? instructorId,
    String? description,
    String? category,
    bool? isOnline,
    String? location,
    String? meetingUrl,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    double? rating,
    String? image,
    int? durationHours,
    bool? isBooked,
    String? enrolledStudentId,
    String? enrolledStudentName,
    DateTime? enrolledAt,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      instructorId: instructorId ?? this.instructorId,
      description: description ?? this.description,
      category: category ?? this.category,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      durationHours: durationHours ?? this.durationHours,
      isBooked: isBooked ?? this.isBooked,
      enrolledStudentId: enrolledStudentId ?? this.enrolledStudentId,
      enrolledStudentName: enrolledStudentName ?? this.enrolledStudentName,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}