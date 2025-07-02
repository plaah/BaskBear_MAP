class BookingModel {
  final String id;
  final String userId;
  final String sessionId;
  final DateTime bookingDate;
  final String status;
  final bool paymentStatus;
  final String? additionalNotes;
  final bool isDone;
  final bool isReview;

  BookingModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.bookingDate,
    this.status = 'pending',
    this.paymentStatus = false,
    this.additionalNotes,
    this.isDone = false,
    this.isReview = false,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      bookingDate: DateTime.parse(map['bookingDate']),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? false,
      additionalNotes: map['additionalNotes'],
      isDone: map['isDone'] ?? false,
      isReview: map['isReview'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
      'paymentStatus': paymentStatus,
      'additionalNotes': additionalNotes,
      'isDone': isDone,
      'isReview': isReview,
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? sessionId,
    DateTime? bookingDate,
    String? status,
    bool? paymentStatus,
    String? additionalNotes,
    bool? isDone,
    bool? isReview,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isDone: isDone ?? this.isDone,
      isReview: isReview ?? this.isReview,
    );
  }
}