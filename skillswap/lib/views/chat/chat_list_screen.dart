import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../models/chat_room_model.dart';
import '../../models/message_model.dart';
import '../../services/session_service.dart';
import 'chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListScreen extends StatefulWidget {
  final bool isInstructor;
  const ChatListScreen({Key? key, this.isInstructor = false}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final FirestoreSessionService _sessionService = FirestoreSessionService();

  Future<String> _getStudentName(String studentId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['name'] ?? 'Student';
    }
    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _chatService.chatRoomsForUser(
          userId: user.uid,
          isInstructor: widget.isInstructor,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(child: Text('No chats yet.'));
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return FutureBuilder(
                future: Future.wait([
                  _chatService.getLastMessage(room.id),
                  _sessionService.getSessionById(room.bookingId),
                  if (widget.isInstructor) _getStudentName(room.studentId),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snap) {
                  if (!snap.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }
                  final Message? lastMsg = snap.data![0] as Message?;
                  final session = snap.data![1];
                  final sessionTitle = session?.title ?? 'Session';
                  String otherName;
                  if (widget.isInstructor) {
                    otherName =
                        snap.data!.length > 2
                            ? (snap.data![2] as String)
                            : 'Student';
                  } else {
                    otherName = session?.instructor ?? 'Instructor';
                  }
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(otherName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sessionTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          lastMsg?.text ?? 'No messages yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Text(
                      lastMsg != null ? _formatTime(lastMsg.timestamp) : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                chatRoom: room,
                                currentUserId: user.uid,
                                otherUserName: otherName,
                                session: session,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
