import 'package:flutter/material.dart';
import 'chat_list_screen.dart';

class OpenChatListButton extends StatelessWidget {
  final bool isInstructor;
  final String? label;
  final IconData? icon;
  final Color? color;
  const OpenChatListButton({
    Key? key,
    this.isInstructor = false,
    this.label,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF667eea),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2,
      ),
      icon: Icon(icon ?? Icons.chat_bubble_outline, color: Colors.white),
      label: Text(
        label ?? (isInstructor ? 'Chat with Students' : 'My Chats'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatListScreen(isInstructor: isInstructor),
          ),
        );
      },
    );
  }
}
