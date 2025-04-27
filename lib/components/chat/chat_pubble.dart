import 'package:flutter/material.dart';
import 'package:graduation_project/Models/chat_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:intl/intl.dart';

/// Custom painter for the little triangle “tail.”
class BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isSender;

  BubbleTailPainter({required this.color, this.isSender = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (isSender) {
      // tail on the right
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    } else {
      // tail on the left
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Your own bubble, aligned left.
class ChatBubble extends StatelessWidget {
  final ChatModel message;
  const ChatBubble({super.key, required this.message, required bool isSender});

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('h:mm a').format(message.createdAt.toDate());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Tail
        CustomPaint(
          painter: BubbleTailPainter(color: const Color(0xFF006D84)),
          size: const Size(8, 16),
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4, right: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006D84), Color(0xFF0099B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  ts,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Friend’s bubble, aligned right, with avatar.
class ChatBubbleForFriend extends StatelessWidget {
  final ChatModel message;
  const ChatBubbleForFriend({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('h:mm a').format(message.createdAt.toDate());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4, left: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: pkColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  ts,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Tail
        CustomPaint(
          painter: BubbleTailPainter(color: pkColor, isSender: true),
          size: const Size(8, 16),
        ),
        const SizedBox(width: 8),
        // Avatar placeholder
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, size: 20, color: Colors.white),
        ),
      ],
    );
  }
}
