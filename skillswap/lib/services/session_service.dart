import 'package:flutter/foundation.dart';
import '../models/session_model.dart';

abstract class SessionService {
  Future<void> createSession(Session session);
  Future<List<Session>> getSessions();
  Future<void> deleteSession(String sessionId);
}

// Mock implementation for demonstration
class SessionMockService implements SessionService {
  final List<Session> _sessions = [];

  @override
  Future<void> createSession(Session session) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
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
}
