import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(
    Map<String, dynamic> map,
    String id,
    String chatRoomId,
  ) {
    return Message(
      id: id,
      chatRoomId: chatRoomId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'senderId': senderId, 'text': text, 'timestamp': timestamp};
  }
}
