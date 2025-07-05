import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get chat room by bookingId
  Future<ChatRoom> createOrGetChatRoom({
    required String bookingId,
    required String studentId,
    required String instructorId,
  }) async {
    final query =
        await _firestore
            .collection('chatRooms')
            .where('bookingId', isEqualTo: bookingId)
            .limit(1)
            .get();
    if (query.docs.isNotEmpty) {
      return ChatRoom.fromMap(query.docs.first.data(), query.docs.first.id);
    }
    final doc = await _firestore.collection('chatRooms').add({
      'bookingId': bookingId,
      'studentId': studentId,
      'instructorId': instructorId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final snap = await doc.get();
    return ChatRoom.fromMap(snap.data()!, doc.id);
  }

  // Send message
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String text,
  }) async {
    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    await chatRoomRef.collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream messages
  Stream<List<Message>> messagesStream(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Message.fromMap(doc.data(), doc.id, chatRoomId))
                  .toList(),
        );
  }

  // Get chat rooms for a user (student or instructor)
  Stream<List<ChatRoom>> chatRoomsForUser({
    required String userId,
    required bool isInstructor,
  }) {
    final field = isInstructor ? 'instructorId' : 'studentId';
    return _firestore
        .collection('chatRooms')
        .where(field, isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get last message for a chat room
  Future<Message?> getLastMessage(String chatRoomId) async {
    final snap =
        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      return Message.fromMap(doc.data(), doc.id, chatRoomId);
    }
    return null;
  }
}
