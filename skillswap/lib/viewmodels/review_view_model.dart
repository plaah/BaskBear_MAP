import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;
  List<ReviewModel> _reviews = [];
  bool _canReview = false;
  bool _hasReviewed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ReviewModel> get reviews => _reviews;
  bool get canReview => _canReview;
  bool get hasReviewed => _hasReviewed;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Submit a review
  Future<void> submitReview({
    required String sessionId,
    required String instructorId,
    required double rating,
    required String comment,
    required int clarityScore,
    required int relevanceScore,
    required int satisfactionScore,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to submit a review');
      }

      // Get student info (you might want to fetch this from Firestore)
      String studentName =
          currentUser.displayName ??
          currentUser.email?.split('@')[0] ??
          'Unknown Student';

      final review = ReviewModel(
        id: '',
        sessionId: sessionId,
        studentId: currentUser.uid,
        studentName: studentName,
        instructorId: instructorId,
        rating: rating,
        comment: comment,
        clarityScore: clarityScore,
        relevanceScore: relevanceScore,
        satisfactionScore: satisfactionScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _reviewService.submitReview(review);

      // Refresh the reviews list and review status
      await loadSessionReviews(sessionId);
      await checkReviewStatus(sessionId, currentUser.uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load reviews for a specific session
  Future<void> loadSessionReviews(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getSessionReviews(sessionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load reviews for a specific instructor
  Future<void> loadInstructorReviews(String instructorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getInstructorReviews(instructorId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if current user can review a session
  Future<void> checkReviewStatus(String sessionId, String studentId) async {
    try {
      _canReview = await _reviewService.canStudentReview(sessionId, studentId);
      _hasReviewed = await _reviewService.hasStudentReviewed(
        sessionId,
        studentId,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get instructor's average rating
  Future<double> getInstructorAverageRating(String instructorId) async {
    try {
      return await _reviewService.getInstructorAverageRating(instructorId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to delete a review');
      }

      await _reviewService.deleteReview(reviewId, currentUser.uid);

      // Refresh the reviews list and review status
      await loadSessionReviews(sessionId);
      await checkReviewStatus(sessionId, currentUser.uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate average rating from current reviews list
  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    double total = _reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }

  // Get rating distribution (1-5 stars)
  Map<int, int> get ratingDistribution {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (ReviewModel review in _reviews) {
      int rating = review.rating.round();
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = distribution[rating]! + 1;
      }
    }

    return distribution;
  }

  // Get total review count
  int get totalReviews => _reviews.length;

  // Get reviews sorted by rating (highest first)
  List<ReviewModel> get reviewsSortedByRating {
    List<ReviewModel> sortedReviews = List.from(_reviews);
    sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedReviews;
  }

  // Get reviews sorted by date (newest first)
  List<ReviewModel> get reviewsSortedByDate {
    List<ReviewModel> sortedReviews = List.from(_reviews);
    sortedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedReviews;
  }

  // Filter reviews by minimum rating
  List<ReviewModel> getReviewsByMinRating(double minRating) {
    return _reviews.where((review) => review.rating >= minRating).toList();
  }

  // Get recent reviews (last 30 days)
  List<ReviewModel> get recentReviews {
    DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _reviews
        .where((review) => review.createdAt.isAfter(thirtyDaysAgo))
        .toList();
  }
}
