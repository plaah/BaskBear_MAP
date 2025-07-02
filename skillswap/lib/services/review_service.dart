import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';
import '../models/booking_model.dart';
import '../models/session_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Submit review with validation
  Future<void> submitReview(ReviewModel review) async {
    try {
      // Validate if student can review this session
      bool canReview = await canStudentReview(review.sessionId, review.studentId);
      if (!canReview) {
        throw Exception('You cannot review this session. Make sure the session is completed and you have made payment.');
      }

      // Check if student has already reviewed this session
      bool hasReviewed = await hasStudentReviewed(review.sessionId, review.studentId);
      if (hasReviewed) {
        throw Exception('You have already reviewed this session.');
      }

      // Submit the review (with all new fields)
      await _firestore.collection('reviews').add(review.toMap());
      
      // Update session's average rating and totalReviews
      await _updateSessionRating(review.sessionId);
      
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  // Get reviews for a specific session
  Future<List<ReviewModel>> getSessionReviews(String sessionId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => 
          ReviewModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get session reviews: $e');
    }
  }

  // Get reviews for a specific instructor
  Future<List<ReviewModel>> getInstructorReviews(String instructorId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('instructorId', isEqualTo: instructorId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => 
          ReviewModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get instructor reviews: $e');
    }
  }

  // Check if student can review (session completed & paid & not already reviewed)
  Future<bool> canStudentReview(String sessionId, String studentId) async {
    // Allow review as long as student has marked as done (handled by UI/booking)
    return true;
  }

  // Check if student has already reviewed this session
  Future<bool> hasStudentReviewed(String sessionId, String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if student has reviewed: $e');
      return false;
    }
  }

  // Check payment status for a booking
  Future<bool> _checkPaymentStatus(String sessionId, String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('sessionId', isEqualTo: sessionId)
          .where('userId', isEqualTo: studentId)
          .where('paymentStatus', isEqualTo: true)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking payment status: $e');
      return false;
    }
  }

  // Update session's average rating
  Future<void> _updateSessionRating(String sessionId) async {
    try {
      // Get all reviews for this session
      final reviews = await getSessionReviews(sessionId);
      
      if (reviews.isEmpty) return;
      
      // Calculate average rating
      double totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
      double averageRating = totalRating / reviews.length;
      
      // Update session document
      await _firestore.collection('sessions').doc(sessionId).update({
        'rating': averageRating,
        'totalReviews': reviews.length,
        'updatedAt': Timestamp.now(),
      });
      
    } catch (e) {
      print('Error updating session rating: $e');
    }
  }

  // Get instructor's average rating
  Future<double> getInstructorAverageRating(String instructorId) async {
    try {
      final reviews = await getInstructorReviews(instructorId);
      
      if (reviews.isEmpty) return 0.0;
      
      double totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
      return totalRating / reviews.length;
    } catch (e) {
      print('Error getting instructor average rating: $e');
      return 0.0;
    }
  }

  // Delete a review (if user is the author)
  Future<void> deleteReview(String reviewId, String studentId) async {
    try {
      // First check if the review belongs to the student
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }
      
      final reviewData = reviewDoc.data() as Map<String, dynamic>;
      if (reviewData['studentId'] != studentId) {
        throw Exception('You can only delete your own reviews');
      }
      
      // Delete the review
      await _firestore.collection('reviews').doc(reviewId).delete();
      
      // Update session rating
      String sessionId = reviewData['sessionId'];
      await _updateSessionRating(sessionId);
      
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}