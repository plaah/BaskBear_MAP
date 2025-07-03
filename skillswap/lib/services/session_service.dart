import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/session_model.dart';

abstract class SessionService {
  Future<void> createSession(Session session);
  Future<List<Session>> getSessions();
  Future<void> deleteSession(String sessionId);
  Future<Session?> getSessionById(String sessionId);
}

class FirestoreSessionService implements SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sessions';


  @override
  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection(_collection).doc(sessionId).delete();
  }

  @override
  Future<void> createSession(Session session) async {
    try {
      debugPrint('Creating session: ${session.title}');
      
      final docRef = await _firestore
          .collection(_collection)
          .add(session.toMap());
      
      debugPrint('Session created with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('Error creating session: $e');
      rethrow;
    }
  }

  @override
  Future<List<Session>> getSessions() async {
    try {
      debugPrint('Loading sessions from Firestore...');
      
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('startDate', descending: false)
          .get();
      
      debugPrint('Found ${snapshot.docs.length} sessions in Firestore');
      
      final sessions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('Session data: ${data['title']}');
        return Session.fromMap(data, doc.id);
      }).toList();
      
      debugPrint('Successfully loaded ${sessions.length} sessions');
      return sessions;
      
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      rethrow;
    }
  }

  @override
  Future<Session?> getSessionById(String sessionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(sessionId).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return Session.fromMap(data, doc.id);
    } catch (e) {
      debugPrint('Error fetching session by ID: $e');
      return null;
    }
  }
}

// Mock implementation for demonstration (keep this for testing)
class SessionMockService implements SessionService {
  final List<Session> _sessions = [];

  @override
  Future<void> createSession(Session session) async {
    await Future.delayed(const Duration(seconds: 1));
    _sessions.add(session);
    debugPrint('Created session: ${session.title}');
  }

  @override
  Future<List<Session>> getSessions() async {
    await Future.delayed(const Duration(seconds: 1));
    return _sessions;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((session) => session.title == sessionId);
  }

  @override
  Future<Session?> getSessionById(String sessionId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _sessions.firstWhere((session) => session.title == sessionId);
  }
}
