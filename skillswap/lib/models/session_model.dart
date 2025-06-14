class Session {
  final String id; 
  final String title;
  final String instructor;
  final String description;
  final String category;
  final bool isOnline;
  final String? location; // Required if offline
  final double price;
  final DateTime startDate;
  final DateTime? endDate;
  final double rating;
  final String image;
  final int durationHours;
  final bool isBooked;

  Session({
    required this.id,
    required this.title,
    this.instructor = 'You',
    required this.description,
    required this.category,
    required this.isOnline,
    this.location,
    required this.price,
    required this.startDate,
    this.endDate,
    this.rating = 0.0,
    this.isBooked = false,
    required this.image,
    required this.durationHours,
  });

  String get durationHour => '$durationHours ${durationHours == 1 ? 'hour' : 'hours'}';

  // Add this method
  factory Session.fromMap(Map<String, dynamic> map, String id) {
    return Session(
      id: id,
      title: map['title'] ?? '',
      instructor: map['instructor'] ?? 'You',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      isOnline: map['isOnline'] ?? false,
      location: map['location'],
      price: (map['price'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      rating: (map['rating'] ?? 0.0).toDouble(),
      image: map['image'] ?? 'https://via.placeholder.com/150',
      durationHours: map['durationHours'] ?? 0,
      isBooked: map['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'instructor': instructor,
      'description': description,
      'category': category,
      'isOnline': isOnline,
      'isBooked' : isBooked,
      'location': location,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'rating': rating,
      'image': image,
      'durationHours': durationHours,
    };
  }
}
